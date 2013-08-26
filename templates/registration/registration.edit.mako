<%! import collections %>
<%inherit file="/page" />
<%namespace name="buttons" file="/buttons"  /> 
<%namespace name="forms" file="/forms"  />

<%def name="registration_edit(rec, prefix='', edit=True)">
	<input type="hidden" name="${prefix}rectype" value="registration" />
	<input type="hidden" name="${prefix}name" value="${rec.get('name','')}" />

	<table class="retreat-signup">
		<tbody>			
					
			<tr>
				<td>I am:</td>
				<td>
					% if edit:
    					<ul class="e2l-nonlist">
    					    ${forms.radios(prefix+'registration_type', ['Faculty', 'Post-doc', 'Student', 'Staff'], value=rec.get('registration_type'), required=True, elem='li')}
                        <ul>
					% else:
						${rec.get('registration_type')}
					% endif
				</td>
			</tr>

            <tr>
                <td>Primary PI:</td>
                <td>
                    % if edit:
                        ${forms.select(prefix+'registration_pi', faculty, value=rec.get('registration_pi'), required=True)}
                    % else:
                        ${rec.get('registration_pi')}
                    % endif
                </td>
            </tr>

			<tr>
				<td>Secondary PI:</td>
				<td>
                    % if edit:
                        ${forms.select(prefix+'registration_pi_secondary', faculty, value=rec.get('registration_pi_secondary'))}
    				    ## &mdash; or &mdash; 
                        ## ${forms.text(prefix+'name_pis_secondary', value=rec.get('registration_pi_secondary'))}
    				    ## <span class="e2l-small">(Firstname Lastname)</span>
                    % else:
						${rec.get('registration_pi_secondary')}
					% endif
				</td>
			</tr>

			<tr>
				<td>I plan to attend:</td>
				<td>
					% if edit:
					    <ul class="e2l-nonlist">
					        <% 
                                days = collections.OrderedDict()
                                days['2013-10-10'] = "Thursday, October 10"
                                days['2013-10-11'] = "Friday, October 11"
					        %>
					        ${forms.checkboxes(prefix+'registration_attend', days, elem='li', values=rec.get('registration_attend'))}
					    </ul>
					% else:
						${", ".join(rec.get('registration_attend',[]))}
					% endif
				</td>
			</tr>

			<tr>
				<td>Presentation:</td>
				<td>
                    <% 
                        pres = collections.OrderedDict()
                        pres['Talk'] = "I would like to present a talk or a poster."
                        pres['Poster'] = "I would like to present a poster."
                        pres[''] = "I prefer not to present."
                    %>
					% if edit:
					    <ul class="e2l-nonlist">
                            ${forms.radios(prefix+"registration_presentation", pres, required=True, value=rec.get('registration_presentation'), elem='li')}
					    </ul>
                        <p>
    						All 3rd year and above students are required to present a talk or a poster.
    						2nd year students and postdocs are encouraged to present talks and posters.
    						You will have until September 23, 2013 to submit and revise abstracts.
                            Maximum poster size is 4 feet by 4 feet.
                        </p>
					% else:
						${pres.get(rec.get('registration_presentation'))}
					% endif
				</td>
			</tr>

			<tr><td colspan="2"><hr/></td></tr>

			<tr>
				<td>Accommodations:</td>
				<td>
				    <% 
				        accom = collections.OrderedDict()
				        accom['decline'] = "I will not need a hotel room."
				        accom['single'] =  "I am a faculty member and will have my own hotel a room."
				        accom['shared'] = "I will be sharing a room, and..."
				    %>
					% if edit:
                        <ul class="e2l-nonlist">
                            ${forms.radios(prefix+'registration_accomodation', accom, required='required', elem='li', value=rec.get('registration_accomodation'))}
                        </ul>
			
						<ul style="padding-left:40px">
							<li>My gender is:
							    ${forms.radios(prefix+'registration_gender', ['Male', 'Female'], value=rec.get('registration_gender'))}
							</li>
							<li>
							    Preferred roommate: 
                                ${forms.text(prefix+'registration_roommate', value=rec.get('registration_roommate'))}
							    <span class="e2l-small">(Firstname Lastname)</span>
							</li>
						</ul>
					% else:

                        ${accom.get(rec.get('registration_accomodation'))}
						% if rec.get('registration_gender'):
							with a ${rec.get('registration_gender')}
							% if rec.get('registration_roommate'):
								-- preferably ${rec.get('registration_roommate')}
							% endif
						% endif

					% endif
				</td>
			</tr>

            <tr>
                <td>Meal preference:</td>
                <td>
                    <% mealpref = {"Vegetarian":"I prefer a vegetarian meal."} %>
                    % if edit:
                        ${forms.checkboxes(prefix+'registration_mealpreferences', mealpref, values=rec.get('registration_mealpreferences'))}
                    % else:
                        ${', '.join(rec.get('registration_mealpreferences', []))}
                    % endif
                </td>
            </tr>

            <tr>
                <tr>
                    <td>T-shirt:</td>
                    <td>
                        <% shirtsizes = ["Men's Small", "Men's Medium", "Men's Large", "Men's XL", "Men's XXL", "Women's Small", "Women's Medium", "Women's Large", "Women's XL", "Women's XXL"] %>
                        % if edit:
                            ${forms.select(prefix+'registration_shirtsize', shirtsizes, value=rec.get('registration_shirtsize'))}
                            <br />Note: Women's sizes tend to run small.
                        % else:
                            ${rec.get('registration_shirtsize')}
                        % endif
                    </td>
                </td>
            </tr>

			<tr><td colspan="2"><hr/></td></tr>

			<tr>
				<td>Charge Source:</td>
				<td>
					% if edit:
					    ${forms.text(prefix+"registration_funding_source", value=rec.get('registration_funding_source'))}
                        <span class="e2l-small">(10-digit account number)</span>
						<p>
    						You must have permission from your PI to attend and you must enter an account to be charged for your attendance. 
    						Please ask your PI or administrator for the charge source number.
					    </p><p>
						    The registration fee is $250.00 per attendee.
						</p>
					% else:
						${rec.get('registration_funding_source')}
					% endif
				</td>
			</tr>

		</tbody>
	</table>
</%def>

<h1>${ctxt.title}</h1>

<form method="post" action="${ctxt.root}/registration/edit/">
	${registration_edit(registration)}
	
	<ul class="e2l-controls">
	    <li><input value="Save Registration" type="submit" class="e2l-big"></li>
	</ul>

</form>
