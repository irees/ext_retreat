<%! import collections %>
<%inherit file="/page" />
<%namespace name="buttons" file="/buttons"  /> 
<%namespace name="forms" file="/forms"  />


<%def name="profile_edit(person)">
	<table class="retreat-signup">	
		<tbody>
			<tr>
				<td style="width:200px">First name:</td>
				<td>
                    ${forms.text('name_first', value=person.get('name_first'), required=True)}
				</td>
			</tr>

			<tr>
				<td>Middle name:</td>
				<td>
                    ${forms.text('name_middle', value=person.get('name_middle'))}
				    <span class="e2l-small">Optional</span>
				</td>
			</tr>

			<tr>
				<td>Last name:</td>
				<td>
                    ${forms.text('name_last', value=person.get('name_last'), required=True)}
				</td>
			</tr>

			<tr>
				<td>Institution:</td>
				<td>
                    <%
                    inst = [
                        'Baylor College of Medicine', 
                        'Rice University', 
                        'MD Anderson Cancer Center', 
                        'University of Texas Health Science Center', 
                        'University of Texas Medical Branch', 
                        'University of Houston', 
                        'Other']
                    %>
                    ${forms.select('institution', inst, value=person.get('institution'), required=True)}
				</td>
			</tr>

			<tr>
                <td>Department:</td>
                <td>
                    <%
                    depts = [
                        'BCM - Biochemistry and Molecular Biology',
                        'BCM - Pharmacology',
                        'Other'
                    ]
                    %>
                    ${forms.select('department', depts, value=person.get('department'))}
                    ## &mdash; or &mdash;                     
                    ## ${forms.text('department', value=person.get('department'))}
                </td>
			</tr>

		</tbody>
	</table>
</%def>


<h1>${ctxt.title}</h1>

<%call expr="buttons.singlepage('Contact information','userinfo1')">
    <form method="post" action="${ctxt.root}/profile/edit/">
    	<input type="hidden" name="name" value="${USER.userrec.get('name')}" />
	
    	${profile_edit(USER.userrec)}
	
    	<ul class="e2l-controls">
    		<li><input value="Save profile" type="submit" class="e2l-big"></li>
    	</ul>
    </form>
</%call>

<%call expr="buttons.singlepage('Change email','userinfo2')">
	<form method="post" action="${ctxt.root}/auth/email/change/">
		<input type="hidden" name="name" value="${USER.name or ''}" />

		<table class="retreat-signup">
			<tbody>
				<tr>
					<td>Current password:</td>
					<td><input required="required" type="password" name="opw" value="" /> <span class="e2l-small">(required to change email)</span></td>
				</tr>
		
				<tr>
					<td>New email:</span>
					<td><input required="required" type="text" name="email" value="${USER.get('email','')}" /></td>
				</tr>
			</tbody>
		</table>

		<ul class="e2l-controls">
			<li><input type="submit" value="Change email" class="e2l-big"></li>
		</ul>
	</form>
</%call>

<%call expr="buttons.singlepage('Change password', 'userinfo3')">
	<form action="${ctxt.root}/auth/password/change/" method="post">
		<input type="hidden" name="name" value="${USER.name or ''}" />
		<table class="retreat-signup">
			<tbody>
				<tr>
					<td>Current password:<td>
					<td><input required="required" type="password" name="opw" /></td>
				</tr>
				<tr>
					<td>New password:<td>
					<td><input required="required" type="password" name="on1" /></td>
				</tr>	
				<tr>
					<td>Confirm new password:<td>
					<td><input required="required" type="password" name="on2" /></td>
				</tr>						
			</tbody>
		</table>
		<ul class="e2l-controls">
			<li><input type="submit" value="Change password" class="e2l-big"></li>
		</ul>		
	</form>	
</%call>
