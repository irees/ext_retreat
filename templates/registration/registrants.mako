<%inherit file="/page" />
<%namespace name="buttons" file="/buttons" /> 
<%namespace name="reg" file="/registration/registration.edit"  /> 
<%namespace name="per" file="/registration/profile.edit"  /> 

<%
import collections
import jsonrpc.jsonutil
users_d = {}
for user in users:
    users_d[user.name] = user
reg_d = {}
for reg in registrations:
    reg_d[reg.name] = reg
%>

<h1>Registrants</h1>

<table class="e2l-shaded" cellspacing="0" cellpadding="0">
    <thead>
        <tr>
            <th>Name</th>
            <th>Contact</th>
            <th>Lab</th>
            <th>Attending</th>
            <th>Presenting</th>
            <th>Accomodations</th>
            <th>Registered</th>
            <th>Charge Source</th>
            <th>Etc.</th>
        </tr>
    </thead>
    <tbody>
        % for user in users:
        <%
        urec = user.get('userrec',dict())
        regs = urec.get('children', set()) & regnames
        if not regs:
            continue
        reg = regs.pop()
        reg = reg_d.get(reg,dict())
        %>
        <tr>
            <td>${user.get('displayname')}</td>
            <td>
                ${user.get('email','')}<br />
                ${urec.get('department')}<br />
                ${urec.get('institution')}
            </td>
            <td>
                ${reg.get('registration_type')}<br />
                ${reg.get('registration_pi')}<br />
                ## ${reg.get('registration_pi_secondary')}                
            </td>
            <td>${', <br />'.join(reg.get('registration_attend') or []) | n}</td>
            <td>${reg.get('registration_presentation')}</td>
            <td>
                ${reg.get('registration_accomodation')}<br />
                ${reg.get('registration_gender','')}<br />
                ${reg.get('registration_roommate','')}
            </td>
            <td>${reg.get('creationtime')[:10]}</td>
            <td>${reg.get('registration_funding_source')}</td>
            <td>
                <a href="${ctxt.root}/registration/abstract/new/?user=${user.name}">New Abstract</a>
            </td>
        </tr>
        % endfor
    </tbody>
</table>

<h1>
    Abstracts
    <a href="${ctxt.root}/registration/admin/abstracts/">Preview</a>
</h1>

<table class="e2l-shaded" cellspacing="0" cellpadding="0">
    <thead>
        <tr>
            <th>Presenter</th>
            <th>PI names</th>
            <th>Title</th>
            <th>Word Count</th>
        </tr>
    </thead>
    <tbody>
        % for abstract in abstracts:
            <%
            if abstract.get('deleted'):
                continue
            wc = abstract.get('registration_abstract_text','')
            wc = len(wc.split())
            %>
        <tr>
            <td>${abstract.get('registration_presenter','')}</td>
            <td>${", ".join(abstract.get('name_pis_string',[]))}</td>
            <td><a href="${ctxt.root}/registration/abstract/${abstract.get('name')}/edit/">${abstract.get('registration_abstract_title','')}</a></td>
            <td>${wc}</td>          
        </tr>
        % endfor
    </tbody>
</table>

<h1>Statistics</h1>

<%
days = collections.defaultdict(set)
pi = collections.defaultdict(set)
charge = collections.defaultdict(set)
presenting = collections.defaultdict(set)
accom = collections.defaultdict(set)
presenting_indicated_pi = collections.defaultdict(set)

presenting_abstracts = collections.defaultdict(set)
presenting_pi = collections.defaultdict(set)

for reg in registrations:
    for day in reg.get('registration_attend',[]):
        days[day].add(reg.name)

    # for i in reg.get('registration_pi',[]):
    pi[reg.get('registration_pi')].add(reg.name)

    charge[reg.get('registration_funding_source')].add(reg.name)
    accom[reg.get('registration_accomodation')].add(reg.name)

    # for p in reg.get('registration_presentation',[]):
    p = reg.get('registration_presentation')
    presenting[p].add(reg.name)
    if p == 'talk':
        presenting_indicated_pi[reg.get('registration_pi')].add(reg.name)
        
        
for abs in abstracts:
    # for p in abs.get('registration_presentation',[]):
    p = abs.get('registration_presentation')
    presenting_abstracts[p].add(abs.name)
    if p == 'talk':
        # presenting_pi[reg.get('registration_pi')].add(abs.name)      
        for i in reg.get('name_pis_string',[]):
            presenting_pi[i].add(abs.name)      
                
%>

<h3>Attendance</h3>
% for day, v in days.items():
    ${day}: ${len(v)} <br />
% endfor

<h3>Attendance by PI</h3>
% for k, v in sorted(pi.items(), key=lambda x:str(x[0]).lower()):
    ${k}: ${len(v)} <br />
 % endfor

<h3>Accomodations</h3>
% for k, v in sorted(accom.items(), key=lambda x:len(x[1]), reverse=True):
    ${k}: ${len(v)} <br />
 % endfor

<h3>Charge Sources</h3>
% for k, v in sorted(charge.items(), key=lambda x:len(x[1]), reverse=True):
    ${k}: ${len(v)} <br />
 % endfor

<h1>Talks &amp; Posters</h1>

<h3>Indicated Abstracts</h3>
% for k, v in presenting.items():
    ${k}: ${len(v)} <br />
% endfor

<h3>Indicated Talks by PI</h3>
% for k, v in presenting_indicated_pi.items():
    ${k}: ${len(v)} <br />
% endfor


<h3>Submitted Abstracts</h3>
% for k, v in presenting_abstracts.items():
    ${k}: ${len(v)} <br />
 % endfor

<h3>Submitted Talks by PI</h3>
% for k, v in presenting_pi.items():
    ${k}: ${len(v)} <br />
 % endfor

