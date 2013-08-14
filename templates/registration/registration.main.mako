<%inherit file="/page" />

<%namespace name="buttons" file="/buttons"  /> 
<%namespace name="reg" file="/registration/registration.edit" /> 
<%namespace name="abs" file="/registration/abstract.edit" /> 

<h1>
	${USER.displayname}
	<span class="label"><a href="${ctxt.root}/profile/edit/"><img src="${ctxt.root}/static/images/edit.png" alt="Edit" /> Edit</a></span>
</h1>

<table class="retreat-signup">
	<tbody>
		<tr>
			<td>Email:</td>
			<td>${USER.email}</td>
		</tr>
	
		<tr>
			<td>Institution:</td>
			<td>${USER.userrec.get('institution', '')}</td>
		</tr>
		<tr>
			<td>Department:</td>
			<td>${USER.userrec.get('department', '')}</td>
		</tr>
	</tbody>
</table>

% if ADMIN:
	<h1>Admin</h1>

    <h3>Registrants</h3>
	<ul>
		<li><a href="${ctxt.root}/registration/admin/registrants/">Registrants</a></li>
		<li><a href="${ctxt.root}/registration/admin/registrants/csv/registrants.csv">Registrant spreadsheet</a></li>
    </ul>

    <h3>Abstracts</h3>
    <ul>
		<li><a href="${ctxt.root}/registration/admin/abstracts/">Preview abstracts</a></li>
		<li><a href="${ctxt.root}/registration/admin/abstracts/html/abstracts.html">Abstracts book</a></li>
    </ul>

    <h3>Judging</h3>
    <ul>
		<li><a href="${ctxt.reverse('Judging/main')}">Judging forms</a></li>
		<li><a href="${ctxt.reverse('Judging/new')}">Enter results</a></li>
		<li><a href="${ctxt.reverse('Judging/results')}">Judging results</a></li>
	</ul>

% endif

<h1>
	Registration
	<a href="${ctxt.root}/registration/edit/"><img src="${ctxt.root}/static/images/edit.png" alt="Edit" /> Edit</a>
</h1>

% if registration:
	${reg.registration_edit(registration, edit=False)}
% else:
	<p>No registrations submitted.</p>
% endif

## <p><a href="${ctxt.root}/auth/logout/"> Logout</a></p>


<h1>
	Abstracts
	% if abstracts:
		(${len(abstracts)})
	% endif
	<a href="${ctxt.root}/registration/abstract/new/"><img src="${ctxt.root}/static/images/edit.png" alt="Edit" /> New</a>
</h1>

${abs.abstracts_view(abstracts)}

% if not abstracts:
	<p>
		No abstracts submitted. 
		% if registration.get('registration_presentation'):
			Since you have indicated that you plan to present a talk or poster, abstract submission is required.</p><p>
		% endif		
		<a href="${ctxt.root}/registration/abstract/new/">Submit a new abstract</a>
	</p>
% endif

<form method="get" action="${ctxt.root}/auth/logout/">
    <ul class="e2l-controls">
		<li><input type="submit" value="Log Out" class="e2l-big" /></li>
	</ul>
</form>
