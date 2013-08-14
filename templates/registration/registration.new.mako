<%inherit file="/page" />
<%namespace name="buttons" file="/buttons" /> 
<%namespace name="reg" file="/registration/registration.edit"  /> 
<%namespace name="per" file="/registration/profile.edit"  /> 

<%
import jsonrpc.jsonutil
%>

<p>Please fill out this form to register for the conference. You will receive an email confirming your registration. After your registration has been approved, you may use the email address and password you provide here to login, edit
your registration details, and submit an abstract for your talk or poster.</p>
	
<form id="form_newuser" action="${ctxt.root}/registration/new/" method="post" enctype="charset=utf-8">

	<%call expr="buttons.singlepage('Create new account','userinfo')">

		<table class="retreat-signup">	
			<tbody>						
				<tr>
					<td style="width:200px">Email:</td>
					<td><input required="required" name="email" type="text" value="${kwargs.get('email','')}"></td>
				</tr>

				<tr>
					<td>Password:</td>
					<td>
						<input required="required" name="password" type="password" value="${kwargs.get('password','')}">
						<span class="e2l-small">Minimum 6 characters</span>
					</td>
				</tr>

				<tr>
					<td>Re-enter password:</td>
					<td>
						<input required="required" name="password2" type="password">
					</td>
				</tr>
			</tbody>
		</table>
	</%call>

	<br />

	<%call expr="buttons.singlepage('Contact information','userinfo2')">
		${per.profile_edit(kwargs)}
	</%call>

	<br />

	<%call expr="buttons.singlepage('Registration Details', 'userinfo3')">
		${reg.registration_edit(kwargs.get('childrec', dict()), prefix='childrec.')}
	</%call>

	<ul class="e2l-controls">
	    <li><input value="Submit" type="submit" class="e2l-big"></li>
	</ul>
	<br />

</form>
