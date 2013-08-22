<%!
import csv
import collections
import cStringIO
import markdown
%>

<%
rename = lambda x:("%s %s"%(x.partition(",")[2].strip(), x.partition(",")[0].strip())).strip()

users_d = {}
for user in users:
	user.getdisplayname(lnf=True)
	users_d[user.name] = user

lastnameindex = {}
for user in users:
	lastnameindex[user.name] = user.userrec.get('name_last','').lower()
lastnameindex['root'] = 'skinner'

abstracts_sorted = sorted(abstracts, key=lambda x:lastnameindex.get(x.creator,''))
abstractids = {}
count = 1
for abstract in abstracts_sorted:
	if abstract.get('registration_presentation') != 'talk':
		abstractids[abstract.name] = count
		count += 1
%>

<html>
<head>
	<style text="text/css">
	    html, body {
	        font-size:12pt;
	    }
	
		.retreat-smallcaps {
	        text-align:center;
	        font-variant:small-caps;
	    }
	</style>
</head>
<body>

<h1>Table of Contents</h1>

<table>
	<thead>
		<tr>
			<th style="text-align:left">Name</th>
			<th style="text-align:left">Type</th>
			<th style="text-align:left">Page</th>
		</tr>
	</thead>
	
	<tbody>
	% for count, abstract in enumerate(abstracts_sorted, pageoffset):
		<tr>
			<td style="padding-right:50px">${abstract.get('registration_presenter')}</td>
			<td style="padding-right:50px">
				% if abstractids.get(abstract.name):
					Poster #${abstractids.get(abstract.name)}
				% else:
					Talk
				% endif
			</td>
			<td>${count}</td>
		</tr>
	% endfor
	</tbody>
</table>

<br clear="all" style="page-break-before:always" />

<h1>Abstracts</h1>

<br clear="all" style="page-break-before:always" />



% for abstract in abstracts_sorted:
	<div class="retreat-smallcaps">
		${markdown.markdown(abstract.get('registration_abstract_title'), safe_mode='escape') | n}
	</div>
	
	<p>
		<strong>${abstract.get('registration_presenter')}</strong>,
		% if abstract.get('registration_abstract_authors', []):
			${', '.join(map(rename, abstract.get('registration_abstract_authors', [])))},
		% endif
		<em>${", ".join(map(rename, abstract.get('name_pis_string', [])))}</em>
	</p>

	${markdown.markdown(abstract.get('registration_abstract_text').replace('\t','').replace('\n','\n\n'), safe_mode='escape').replace('<p>','<p align="justify" style="text-align:justify;text-justify:inter-ideograph">').replace('</p>','</p>') | n}

	<br clear="all" style="page-break-before:always" />
% endfor

</body>
</html>
