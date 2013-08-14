<%namespace name="buttons" file="/buttons"  /> 

<html>
    <head>
        <style type="text/css">
            /* body and top level containers */
            html,
            body
            {
                font-family: arial, Verdana, Helvetica, sans-serif;
                font-size: 12pt;
            }
            h1 {
                border-bottom: solid 1px;
                font-size: 18pt;
            }
            .posters {
                border: dashed 2px black;
                margin: 10px;
                padding: 10px;
                font-size: 18pt;
                text-align: center;
            }
            .posters span {
                margin: 20px;
                font-weight: bold;
            }
            .scores {
                width: 300px;
                margin-left: auto;
                margin-right: auto;
            }
            .scores td {
                font-size: 18pt;
                padding: 10px;
            }
            .scores td.rank {
            }
            .scores td.result {
                border-bottom: solid 2px black;
                width: 200px;
            }
            p.center {
                text-align:center;
            }
        </style>
    </head>
<body>

<%
import collections
import random

reg_d = {}
for reg in registrations:
    reg_d[reg.name] = reg

abs_d = {}  
for abs in abstracts:
    abs_d[abs.name] = abs
    
users_d = {}

def namefilt(name):
    lastname = name.split()[-1].strip().lower()
    firstinitial = name[0].lower()
    return '%s %s'%(firstinitial, lastname)
    
def namefilt2(name):
    name = name.partition(",")
    lastname = name[0].strip().lower()
    firstinitial = name[2][0].lower()
    return '%s %s'%(firstinitial, lastname)
    
        
    
rows = []
ok_by_user = {}

for user in users:
    users_d[user.name] = user
    if not user.userrec:
        continue

    # Find posters that I can judge
    # 1. This means that I can't have the same PI,
    # 2. or have my last name on their author list,
    # 3. person cant have the same last name as anyone on my poster list.

    # Check that I registered
    my_registration = user.userrec.children & set(reg_d.keys())
    if not my_registration:
        continue
    
    my_registration = reg_d[my_registration.pop()]
    # Note: we decided not to exclude staff. It can be done instead
    # at form handout time.
    # if my_registration.get('registration_type') == 'staff':
    #   print "Skipping staff ", user.displayname
    #   continue

    # My filtered name
    my_lastname = namefilt(user.userrec.get('name_last'))
    
    # Check my PI
    # print user.displayname, "PI:", reg.get('name_pis_string')
    my_pis = set(map(namefilt, my_registration.get('name_pis_string', []))) 
    my_authors = set()
    
    # Look up my abstracts
    my_abstracts = map(abs_d.get, user.userrec.children & set(abs_d.keys()))
    for abstract in my_abstracts:
        my_pis |= set(map(namefilt, abstract.get('name_pis_string', [])))
        my_authors |= set(map(namefilt, abstract.get('registration_abstract_authors', [])))
    
    # The total of my affiliations
    # my_affiliations = my_authors | my_pis | set([my_lastname])
    my_affiliations = my_pis | set([my_lastname])
    
    judge_ok = set()
    judge_excluded = set()

    # Ok, now look at each poster.
    for abstract in abstracts:
        if abstract.get('registration_presentation') == 'talk':
            # print 'Skipping talk %s'%abstract.name
            continue
    
        their_lastname = namefilt(abstract.get('registration_presenter'))
        # their_pis = set(map(namefilt, abstract.get('name_pis_string', [])))
        # their_pis = set(map(namefilt, [abstract.get('registration_pi'), abstract.get('registration_pi_secondary')]))
        their_pis = filter(None, [abstract.get('registration_pi'), abstract.get('registration_pi_secondary')])
        their_pis = set(map(namefilt2, their_pis))
        their_authors = set(map(namefilt, abstract.get('registration_abstract_authors', [])))
        
        # The total of their affiliations
        their_affiliations = their_pis | their_authors | set([their_lastname])
        
        if not abstract.get('registration_poster_number'):
            print "Poster record ID %s has no registration_poster_number, skipping!!"%abstract.get('registration_poster_number')
        
        common = my_affiliations & their_affiliations
        if common:
            print "\n\n---- %s (PI: %s) **CANNOT** judge:"%(user.displayname, my_pis)
            judge_excluded.add(abstract.get('registration_poster_number'))
            print "Poster: ", abstract.get('registration_abstract_title')
            print "\tpresenter:", abstract.get('registration_presenter')
            print "\tauthors:", abstract.get('registration_abstract_authors')
            print "\tpis:", abstract.get('name_pis_string')
            print "common any:", common
            print "common PIs:", my_pis & their_pis
            print "common authors:", my_authors & their_authors     
        else:
            print "\n\n---- %s (PI: %s) can judge:"%(user.displayname, my_pis)
            judge_ok.add(abstract.get('registration_poster_number'))

        
    print "\n# %s can judge %s posters, excluded from %s"%(user.displayname, len(judge_ok), len(judge_excluded))        
    ok_by_user[user.name] = set() | judge_ok

sampled = collections.defaultdict(set)
JUDGE_COUNT = 5

posters_all = set()
for k,v in ok_by_user.items():
    posters_all |= v

# print "All posters:"
# print len(all_posters)


# Randomize the list of posters and make a deque (double ended queue)
p = list(posters_all)
random.shuffle(p)
poster_queue = collections.deque(p)

for count in []: #range(JUDGE_COUNT):
    print "\n\n==== ROUND %s ====\n\n"%count
    for user, posters in ok_by_user.items():
        print "-- %s"%users_d.get(user).displayname
        # Grab the first matching poster from the queue
        p = None
        not_found = []
        while not p:
            # print poster_queue
            p = poster_queue.pop()

            if p not in posters:
                # We didn't find the poster, put it in the not found queue
                # These will be appended back to the list when we're done
                print "... conflict with: %s"%p
                not_found.append(p)
                p = None
            elif p in sampled[user]:
                # Already assigned to judge
                not_found.append(p)
                p = None
            else:
                # We found the poster. Use it, and put it back 
                # at the end of the queue.
                poster_queue.appendleft(p)

        for i in reversed(not_found):
            poster_queue.append(i)
        
        # print p   
        # print "Got p:", p
        # print "It took %s tries to find a poster... Skipped: %s"%(len(not_found), not_found)
        sampled[user].add(p)
        

ok_by_user = sampled



judges_by_poster = collections.defaultdict(set)
for k,v in ok_by_user.items():
    for poster in v:
        judges_by_poster[poster].add(k)

%>


<h1>Number of judges per poster</h1>

<table class="e2l-kv">
    <thead>
        <tr>
            <th>Poster</th>
            <th># Judges assigned</th>
        </tr>
    </thead>
    <tbody>
        % for poster, judges in sorted(judges_by_poster.items(), key=lambda x:len(x[1])):
            <tr>
                <td>${poster}</td>
                <td>${len(judges)}</td>
            </tr>
        % endfor
    
    <tbody>
</table>

<h1>Number of posters per judge</h1>

<table class="e2l-kv">
    <thead>
        <tr>
            <th>Judge</th>
            <th># of posters assigned</th>
        </tr>
    </thead>
    <tbody>
        % for judge, posters in sorted(ok_by_user.items(), key=lambda x:users_d.get(x[0], dict()).userrec.get('name_last',1)):
            <tr>
                <td>${users_d[judge].displayname}</td>
                <td>${len(posters)}</td>
            </tr>
        % endfor
    </tbody>
</table>

<br clear="all" style="page-break-before:always" />


% for username, targets in sorted(ok_by_user.items(), key=lambda x:users_d.get(x[0], dict()).userrec.get('name_last',1)):
    <%
    user = users_d.get(username)
    %>
    <h1>${user.displayname.title()}</h1>
    
    <p>Please rank the following posters:</p>

    <div class="retreat-posters">
        % for t in sorted(targets):
            <span>&nbsp;&nbsp;${t}&nbsp;&nbsp;</span>
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
                <td class="retreat-result">&nbsp;</td>
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

    <br clear="all" style="page-break-before:always" />

% endfor    


</body>
</html>
