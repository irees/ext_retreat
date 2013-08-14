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
for abstract in abstracts:
    abstract_d[abstract.name] = abstract
    
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

user_conflicts = {}
abstract_conflicts = {}

for user in users:
    user_d[user.name] = user
    if not user.userrec:
        continue

    # Find posters that I can judge
    # 1. This means that I can't have the same PI,
    # 2. or have my name on their author list,
    # 3. person cant have the same name as anyone on my poster list.

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
    
    user_conflicts[user.name] = namefilt(conflicts)
    print "Conflicts for user:", user.displayname
    print user_conflicts[user.name]

# Skip talks
# abstracts = filter(lambda x:x.get('registration_presentation') != 'talk', all_abstracts)

# Ok, now look at each poster.
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
            pass

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

judged = {}

# pairs = mtx([i.name for i in abstracts*10])
pairs = compared.keys()

import copy
p = copy.copy(pairs)
random.shuffle(p)
p = collections.deque(pairs)

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
            # posters = list(posters)
            # random.shuffle(posters)
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
                font-size: 24pt;
            }
            .retreat-posters {
                border: dashed 2px black;
                width: 65%;
                margin-left: auto;
                margin-right: auto;
                padding: 15px;
                font-size: 18pt;
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
                font-size: 18pt;
            }
            .retreat-result {
                border-bottom:solid 2px black;
                padding: 20px;
            }
            .retreat-scores {
                font-size: 18pt;
                padding: 20px;
                width: 400px;
            }
            
            table.retreat-stats thead th,
            table.retreat-stats thead td {
                border-bottom:solid 1px #ccc;
            }
            table.retreat-stats tbody tr:nth-child(even) { background-color:#eee; }

            .retreat-stats td {
                padding:5px;
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
                font-size:18pt;
                page-break-before:always
            }
            
            @media print
            {
            }
            
        </style>
    </head>
<body>

<h1>Statistics</h1>

(Note: poster record IDs, not poster #s)<br />

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
        <td>${count} out of ${cells} (${"%5.1f"%(100*count/float(cells))}% )</td>
    </tr>
    

    % for v in sorted(set(comp_count.values())):
        <tr>
            <td><strong>${v}</strong></td>
            <td>${comp_count.values().count(v)/2}</td>
        </tr>
    % endfor
    
    <tr>
        <%
        _jpp = map(len, judged_by.values())
        %>
        <td><strong>Judges per poster:</strong></td>
        <td>
             ${min(_jpp)} - ${max(_jpp)} (average: ${"%5.1f"%(sum(_jpp) / float(len(judged_by)))})
        </td>
    </tr>
    % for v in sorted(set(_jpp)):
        <tr>
            <td><strong>${v}</strong></td>
            <td>${_jpp.count(v)}</td>
        </tr>
    % endfor

    
</table>

<h3>Comparisons</h3>

<table class="retreat-stats" id="retreat-comparisons"  cellpadding="0" cellspacing="0">
    <thead>
        <tr>
            <td></td>
            % for key in sorted(abstract_d):
                <td><strong>${key}</strong></td>
            % endfor
        </tr>
    </thead>
    
    <tbody>
        % for key in sorted(abstract_d, reverse=True):
            <tr>
                <td><strong>${key}</strong></td>
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
            ## <th>ID</td>
            <th>Name</td>
            <th>Total</th>
            <th>Poster ID (Poster #)</th>
        </tr>
    </thead>
    % for user, posters in judged.items():
        <tr>
            ## <td>${user_d[user].name}</td>
            <td>${user_d[user].displayname}</td>
            <td>${len(posters)}</td>
            <td>
                % for poster in posters:
                    ${poster}
                    (${abstract_d[poster].get('registration_poster_number')}) <br />
                % endfor
            </td>
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
            <td>${abstract_d[poster].get('registration_poster_number')}</td>
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
                ${abstract_d[poster].get('registration_poster_number')}
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
    
    
</body>
</html>
