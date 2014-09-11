<%!
import collections
import random
%>

<%
COUNT = 5

registration_d = {}
for registration in registrations:
    registration_d[registration.name] = registration

abstract_d = {}  
abstract_number = {}
for abstract in abstracts:
    abstract_d[abstract.name] = abstract
    abstract_number[abstract.name] = abstract.get('registration_poster_number')
    
abstract_names = set([abstract.name for abstract in abstracts])
POSTER_NUMS = {}

user_d = {}
for user in users:
    user_d[user.name] = user    

def mtx(keys):
    key = sorted(keys)
    ret = []
    for i in keys:
        for j in keys:
            if i == j:
                break
            ret.append((i,j))
    return ret

def samplemin(d, count=1, reverse=False):
    ret = []
    values = collections.defaultdict(list)
    for k,v in d.items():
        values[v].append(k)
    
    for k,v in sorted(values.items(), reverse=reverse):
        ret.extend(v)
        if len(ret) >= count:
            return ret
    return ret
    
def namefilt(names):
    ret = []
    for name in names:
        name = initials(name)
        if name:
            ret.append(name)
    return set(ret)
    
def initials(name):
    if not name:
        return
    if "," in name:
        name = name.partition(",")
        name = "%s %s"%(name[2], name[0])
    name = name.split()
    lastname = name[-1].strip().lower()
    initial = name[0].strip()[0].lower()
    ret = "%s %s"%(initial, lastname)
    return ret.strip()


###############
##### Go! #####
###############

user_conflicts = {}
user_even = {}
user_numbers = {}
abstract_conflicts = {}

for user in users:
    # Find posters that I can judge
    # 1. This means that I can't have the same PI,
    # 2. or have my name on their author list,
    # 3. person cant have the same name as anyone on my poster list.
    user_d[user.name] = user
    if not user.userrec:
        continue

    # Check that I registered
    my_registration = user.userrec.children & set(registration_d.keys())
    if not my_registration:
        # print "No registration for user:", user.displayname
        continue
    
    my_registration = registration_d[my_registration.pop()]
    # Note: we decided not to exclude staff. It can be done instead
    # at form handout time.
    # if my_registration.get('registration_type') == 'staff':
    #   print "Skipping staff ", user.displayname
    #   continue

    # My name
    conflicts = set()
    conflicts.add(user.displayname)
    
    # Check my PI
    conflicts.add(my_registration.get('registration_pi'))
    conflicts.add(my_registration.get('registration_pi_secondary'))

    # Look up my abstracts
    my_abstracts = map(abstract_d.get, user.userrec.children & set(abstract_d.keys()))
    for abstract in my_abstracts:
        conflicts |= set(abstract.get('name_pis_string', []))
        conflicts |= set(abstract.get('registration_abstract_authors', []))

    # This part is tricky. If the user has an EVEN NUMBERED POSTER, they can only 
    # do detailed evaluation on an ODD NUMBERED POSTER. Also, the converse.
    # If user has NO POSTERS, they can judge both even and odd.
    # If user has MULTIPLE POSTERS, with EVEN AND ODD, then they can judge both. 
    #   -- I don't have a better way to handle that.
    numbers = [abstract_number[abstract.name] for abstract in my_abstracts]
    user_numbers[user.name] = numbers
    numbers_even = map(lambda x:x%2 == 0, filter(None, numbers))
    if numbers_even and all(numbers_even):
        user_even[user.name] = True
    elif True in numbers_even:
        user_even[user.name] = None
    elif False in numbers_even:
        user_even[user.name] = False
    else:
        user_even[user.name] = None

    user_conflicts[user.name] = namefilt(conflicts)
    print "Conflicts for user:", user.displayname
    print user_conflicts[user.name]

# Ok, now look at each poster. Find every possible conflict.
for abstract in abstracts:
    conflicts = set()
    conflicts.add(abstract.get('registration_presenter'))
    conflicts.add(abstract.get('registration_pi'))
    conflicts.add(abstract.get('registration_pi_secondary'))
    conflicts |= set(abstract.get('name_pis_string', []))
    conflicts |= set(abstract.get('registration_abstract_authors', []))
    abstract_conflicts[abstract.name] = namefilt(conflicts)
    # print "Conflicts for poster:", abstract.name
    # print abstract_conflicts[abstract.name]

# Check for conflicts
matches = collections.defaultdict(set)
user_excluded = collections.defaultdict(set)
for k, v in user_conflicts.items():
    u = user_d[k]
    for k2,v2 in abstract_conflicts.items():
        # print "Checking conflicts..."
        # print "\tuser: ", u.displayname, k
        # print "\t...", v
        # print "\tabstract:", k2
        # print "\t...", v2
        if not (v & v2):
            # print "\tNo conflict, adding poster"
            matches[k].add(k2)
        else:
            # print "\tConflicts! not adding poster:", v & v2
            user_excluded[k].add(k2)

# compared = collections.defaultdict(set)
compared = {}
judged_by = {}
judged_total = {}
for i in abstracts:
    judged_by[i.name] = set()
    judged_total[i.name] = 0
    for j in abstracts:
        if i == j:
            break
        compared[(i.name,j.name)] = set()
        compared[(j.name,i.name)] = set()


import copy
judged = {}

for r in range(COUNT):
    print "\nRound: ", r
    u = matches.items()
    random.shuffle(u)
    for user, posters in u:
        print "\nUser:", user

        j = judged.get(user, [])
        if not j:
            # Seed with the first poster
            p = {}
            for poster in posters:
                p[poster] = len(judged_by[poster])
            f = samplemin(p)
            random.shuffle(f)
            judged[user] = [f[0]]
            judged_by[f[0]].add(user)
            
        else:
            # Evaluate all posters we can judge, find a 
            # new poster that avoids any already sampled
            # comparisons
            p = {}
            for poster in posters:
                if poster in j:
                    continue
                cost = 0
                for pair in mtx(j+[poster]):
                    cost -= len(compared[pair])
                p[poster] = cost
                
            f = samplemin(p, reverse=True)
            random.shuffle(f)
            judged[user] = j+[f[0]]
            for i,j in mtx(judged[user]):
                compared[(i,j)].add(user)
                compared[(j,i)].add(user)
                judged_by[i].add(user)
                judged_by[j].add(user)


# Detailed posters
user_detailed = {}
for username, posters in judged.items():
    matched_numbers = set([abstract_number[i] for i in matches.get(username, [])])
    poster_numbers = set([abstract_number[i] for i in posters])
    
    # Filter by poster session EVEN / ODD
    if user_even[username] == True:
        poster_numbers = filter(lambda x:x%2 == 1, poster_numbers)
        matched_numbers = filter(lambda x:x%2 == 1, matched_numbers)
    if user_even[username] == False:
        poster_numbers = filter(lambda x:x%2 == 0, poster_numbers)
        matched_numbers = filter(lambda x:x%2 == 0, matched_numbers)

    if len(poster_numbers) == 0:
        detail = random.sample(matched_numbers, 2)
    elif len(poster_numbers) == 1:
        detail = random.sample(poster_numbers, 1) + random.sample(matched_numbers, 1)
    elif len(poster_numbers) > 1:
        detail = random.sample(poster_numbers, 2)
    user_detailed[username] = detail

%>

<html>
    <head>
        <style type="text/css">
            /* body and top level containers */
            html,
            body
            {
                font-family: arial, Verdana, Helvetica, sans-serif;
            }
            h1 {
                border-bottom: solid 1px;
                font-size: 22pt;
            }
            .retreat-posters {
                border: dashed 2px black;
                width: 80%;
                margin-left: auto;
                margin-right: auto;
                padding: 15px;
                text-align: center;
            }
            .retreat-posters span {
                margin: 20px;
                font-weight: bold;
            }
            .retreat-scores {
                margin-left: auto;
                margin-right: auto;
            }
            .retreat-rank {
                width: 40px;
            }
            .retreat-result {
                border-bottom:solid 2px black;
                padding: 20px;
            }
            .retreat-scores {
                padding: 20px;
                width: 400px;
            }

            table.retreat-stats thead th,
            table.retreat-stats thead td {
                border-bottom:solid 1px #ccc;
            }
            table.retreat-stats tbody tr:nth-child(even) { background-color:#eee; }

            .retreat-stats td {
                padding:10px;
            }
            
            #retreat-comparisons {
                font-size:8pt;
            }
            #retreat-comparisons td {
                padding:2px;
            }
            #retreat-comparisons tbody td:first-child {
                border-right:solid 1px #ccc;
            }
            
            table td, table th {
                padding:2px;
            }
            p.retreat-center {
                text-align:center;
            }
            
            .retreat-form {
                font-size:14pt;
                page-break-before:always
            }
            
            @media print
            {
            }
            
        </style>
    </head>
<body>

<h1>Statistics</h1>

<%
count = 0
for k,v in compared.items():
    if v:
        count += 1
count /= 2

comp_count = {}
for k,v in compared.items():
    if len(v):
        comp_count[k] = len(v)

cells = sum(range(len(abstract_d)))


detailed_eval = {}
for k,v in abstract_number.items():
    detailed_eval[v] = set()
for k,v in user_detailed.items():
    for v2 in v:
        detailed_eval[v2].add(k)

detailed_eval_count = collections.defaultdict(int)
for k,v in detailed_eval.items():
    detailed_eval_count[len(v)] += 1

%>

<h3>Overview</h3>

<table class="retreat-stats"  cellpadding="0" cellspacing="0">
    <tr>
        <td><strong>Abstracts:</strong>
        <td>${len(abstract_d)}</td>
    </tr>

    <tr>
        <td><strong>Judges:</strong>
        <td>${len(judged)}</td>
    </tr>

    <tr>
        <td><strong>Comparisons:</strong>
        <td>${sum(comp_count.values())/2}</td>
    </tr>

    <tr>
        <td><strong>Coverage:</strong>
        <td>${count} out of ${cells} (${"%5.1f"%(100*count/float(cells or 1))}% )</td>
    </tr>
    

    % for v in sorted(set(comp_count.values())):
        <tr>
            <td><strong>${v}</strong></td>
            <td>${comp_count.values().count(v)/2}</td>
        </tr>
    % endfor
    
    <tr>
        <%
        _jpp = map(len, judged_by.values()) or [0]
        %>
        <td><strong>Judges per poster:</strong></td>
        <td>
             ${min(_jpp)} - ${max(_jpp)} (average: ${"%5.1f"%(sum(_jpp) / float(len(judged_by) or 1))})
        </td>
    </tr>
    % for v in sorted(set(_jpp)):
        <tr>
            <td><strong>${v}</strong></td>
            <td>${_jpp.count(v)}</td>
        </tr>
    % endfor
    
    
    <tr>
        <td><strong>Detailed evaluations per poster:</strong>
        <td>${min(detailed_eval_count.keys())} - ${max(detailed_eval_count.keys())}</td>
    </tr>
    % for k,v in sorted(detailed_eval_count.items()):
        <tr>
            <td><strong>${k}</strong></td>
            <td>${v}</td>
        </tr>
    % endfor

    
</table>

<h3>Comparisons</h3>

<table class="retreat-stats" id="retreat-comparisons"  cellpadding="0" cellspacing="0">
    <thead>
        <tr>
            <td></td>
            % for key in sorted(abstract_d):
                <td style="width:15px"><strong>${abstract_number[key]}</strong></td>
            % endfor
        </tr>
    </thead>
    
    <tbody>
        % for key in sorted(abstract_d):
            <tr>
                <td><strong>${abstract_number[key]}</strong></td>
                % for key2 in sorted(abstract_d):
                    % if key == key2:
                        <td style="background:#ccc"> </td>
                    % else:
                        <td>
                            ${len(compared.get((key,key2), [])) or ''}
                        </td>
                    % endif
                % endfor
            </tr>
        % endfor
    </tbody>
</table>

<h3>Judges</h3>
<table class="retreat-stats" cellpadding="0" cellspacing="0">
    <thead>
        <tr>
            <th>Name</td>
            <th>Own posters</th>
            <th>Excluded</th>
            <th>Judged</th>
            <th>Detailed</th>
        </tr>
    </thead>
    % for user, posters in judged.items():
        <tr>
            <td>${user_d[user].displayname} </td>
            <td>${", ".join(map(str, user_numbers[user]))} </td>
            <td>${", ".join(map(str, [abstract_number[i] for i in user_excluded[user]]))} </td>
            <td>${", ".join(map(str, [abstract_number[i] for i in posters]))} </td>
            <td>${", ".join(map(str, [i for i in user_detailed[user]]))} </td>
        </tr>
    % endfor
</table>


<h3>Posters</h3>
<table  class="retreat-stats" cellpadding="0" cellspacing="0">
    <thead>
        <tr>
            ## <th>ID</th>
            <th>Poster #</th>
            <th>Title</th>
            <th>Total</th>
            <th>Judge ID (Judge name)</th>
        </tr>
    </thead>
    % for poster, u in sorted(judged_by.items(), key=lambda x:len(x[1]), reverse=True):
        <tr>
            ## <td>${abstract_d[poster].name}</td>
            <td>${abstract_number[poster]}</td>
            <td>${abstract_d[poster].get('registration_abstract_title')}</td>
            <td>${len(u)}</td>
            <td style="width:400px">
                ## ${", ".join(u)}
                % for user in u:
                    ## ${user}
                    ${user_d[user].displayname}<br />
                % endfor
            </td>
    % endfor
</table>

<h1>Detailed evaluations</h1>




    
<h1>Judging forms</h1>

% for username, posters in sorted(judged.items()):
    <%
    user = user_d.get(username)
    %>

    <div class="retreat-form"> 

    <h1>${user.displayname.title()}</h1>
    
    <p>Please rank the following posters:</p>

    <div class="retreat-posters">
        % for poster in sorted(posters):
            <span>
                &nbsp;&nbsp;
                ${abstract_number[poster]}
                &nbsp;&nbsp;
            </span>
        % endfor
    </div>
    
    <div class="retreat-scores">
        <table cellpadding="0" cellspacing="0" style="width:100%">
            <tr>
                <td class="retreat-rank">1<sup>st</sup></td>
                <td class="retreat-result">&nbsp; </td>
            </tr>

            <tr>
                <td class="retreat-rank">2<sup>nd</sup></td>
                <td class="retreat-result">&nbsp; </td>
            </tr>

            <tr>
                <td class="retreat-rank">3<sup>rd</sup></td>
                <td class="retreat-result">&nbsp; </td>
            </tr>

            <tr>
                <td class="retreat-rank">4<sup>th</sup></td>
                <td class="retreat-result">&nbsp; </td>
            </tr>

            <tr>
                <td class="retreat-rank">5<sup>th</sup></td>
                <td class="retreat-result">&nbsp; </td>
            </tr>
        </table>
    </div>

    <p class="retreat-center">
        <strong>Write <em>ONE</em> poster number per line. No ties</strong>. <br />
        Turn in your ranking sheet to <strong>Ruth</strong> by <strong>11am</strong>.
    </p>

    <p>
        Judging criteria:
    </p>
    
    <ul>
        <li>POSTER (40%)
            <ul>
                <li>Organization of poster, clear flow, aesthetics</li>
                <li>Abstract, hypothesis or questions, conclusions, acknowledgments</li>
                <li>Legible figures, clearly &amp; concisely labeled</li>
            </ul>
        </li>
        <li>RESEARCH (60%)
            <ul>
                <li>Significance for biomedical or basic science</li>
                <li>Quality of data, difficulty of experiments</li>
                <li>Interpretations justified, conclusions sound</li>
                <li>Innovation of approach or techniques</li>
                <li>Percentage of work done by presenter</li>
            </ul>
        </li>
    </ul>

    <p>
        Please rank <strong>all</strong> of your assigned posters.
        We have filtered your assigned posters for conflicts of interest, but if you feel there is a significant conflict, please see Ruth.
    </p>

    </div>
% endfor   


<h1>Detailed Judging forms</h1>

% for username, posters in sorted(user_detailed.items()):
    <%
    user = user_d.get(username)
    
    cats = [
    "Titles, Authors, Affiliations",
    "Abstract for the Program Book",
    "Description and Background",
    "Big Question or Gap",
    "Hypothesis / Model",
    "Methods and Results",
    "Interpretations and Model",
    "Visual presentation",
    "Oral presentation"
    ]
    
    
    %>
    % for poster in posters:
        <div class="retreat-form"> 
        <h1>${user.displayname.title()}</h1>
        <h3>Detailed evaluation for Poster ${poster}</h3>
        
        <table width="100%">
            % for cat in cats:
            <tr>
                <td width="60%">
                    <strong>${cat}</strong>
                    <br />Comments &amp; suggestions:<br /><br /><br />
                </td>
                <td valign="top"><strong>0 &nbsp;&nbsp;&nbsp; 1 &nbsp;&nbsp;&nbsp; 2 &nbsp;&nbsp;&nbsp; 3<strong></td>
            </tr>
            % endfor
        </table>


        </div>
    % endfor
% endfor
    
    
</body>
</html>
