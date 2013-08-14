<%inherit file="/page" />
<%namespace name="abs" file="/registration/abstract.edit" /> 
<h1>
	Abstracts
	% if abstracts:
		(${len(abstracts)})
	% endif
</h1>

${abs.abstracts_view(abstracts)}

<h1>Assign numbers</h1>

<%
lastnameindex = {}
for user in users:
    lastnameindex[user.name] = user.userrec.get('name_last', '').lower()
    
lastnameindex['root'] = 'skinner'

abstracts_sorted = sorted(abstracts, key=lambda x:lastnameindex.get(x.creator,''))

abstract_numbers = {}
count = 1
for abstract in abstracts_sorted:
	if abstract.get('registration_presentation') != 'talk':
		abstract_numbers[abstract.name] = count
		count += 1    
%>

<form method="post" action="${ctxt.root}/registration/admin/abstracts/save/">
    <table class="retreat-stats" cellpadding="0" cellspacing="0">
        <thead>
            <tr>
                <th>ID</th>
                <th>Author</th>
                <th>Title</th>
                <th>Talk</th>
                <th>Poster #</th>
            </tr>
        </thead>

        <tbody>
            % for abstract in abstracts_sorted:
                <tr>
                    <td>${abstract.name}</td>
                    <td>${abstract.get('registration_presenter')}</td>                    
                    <td>${abstract.get('registration_abstract_title')}</td>
                    <td><input name="${abstract.name}.registration_presentation" type="text" value="${abstract.get('registration_presentation') or ''}" /></td>
                    <td><input name="${abstract.name}.registration_poster_number" type="text" value="${abstract.get('registration_poster_number') or ''}" /></td>
                    <td>${abstract_numbers.get(abstract.name)}
                </tr>
            % endfor
        </tbody>

    </table>

    <input type="submit" value="Save" />
</form>