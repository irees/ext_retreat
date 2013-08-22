<%inherit file="/page" />
<%namespace name="forms" file="/forms"  />

<%def name="abstracts_view(abstracts)">
	<% import markdown %>
	<table class="retreat-signup retreat-abstracts" cellpadding="0" cellspacing="0">
		% for count, abs in enumerate(abstracts):
			<tbody>
				<tr>
					<td>${"".join(map(lambda x:x.capitalize(),abs.get('registration_presentation',[])))} Title:</td>
					<td class="retreat-smallcaps">
						${markdown.markdown(abs.get('registration_abstract_title','No Title').replace('\t','').replace('\n','\n\n'), safe_mode='escape') | n}
						(<a href="${ctxt.root}/registration/abstract/${abs.get('name')}/edit/">Edit</a>)
					</td>
				</tr>
				<tr>
					<td>Authors:</td>
					<td>
						${", ".join([abs.get('registration_presenter') or '']+abs.get('registration_abstract_authors',[])+abs.get('name_pis_string',[]))}
					</td>
				</tr>
				<tr>
					<td>Abstract:</td>
					<td>
						${markdown.markdown(abs.get('registration_abstract_text','').replace('\t','').replace('\n','\n\n'), safe_mode='escape') | n}
					</td>
				</tr>

				% if count+1 < len(abstracts) and len(abstracts) > 1:
					<tr><td colspan="2"><hr/></td></tr>
				% endif
			</tbody>
		% endfor
	</table>
</%def>




<%def name="abstract_edit(abstract, edit=True, registration_presenter=None)">
	<%
	def iftrue(exp, value):
		if exp:
			return value

	checked = 'checked="checked"'
	selected = 'selected="selected"'
	%>

	<input type="hidden" name="rectype" value="registration_abstract" />
	% if abstract.get('name') != None:
		<input type="hidden" name="name" value="${abstract.get('name')}" />
	% endif	

	<table class="retreat-signup">
		<tbody>
			<tr>
				<td>Title:</td>
				<td>
				    <input required="required" type="text" style="width:100%" name="registration_abstract_title" value="${abstract.get('registration_abstract_title','')}">
				    </td>
			</tr>


			<tr><td colspan="2"><hr/></td></tr>

			<tr>
				<td>Presenter:</td>
				<td><input required="required" type="text" name="registration_presenter" value="${abstract.get('registration_presenter') or registration_presenter or ''}" /> <span class="e2l-small">(Firstname Lastname)
				</td>
			</tr>

			<tr>
				<td>
					Additional Authors:
				</td>
				<td>
					<ul class="e2l-nonlist">

					% for i in abstract.get('registration_abstract_authors',[]):
						<li>
							<input type="text" name="registration_abstract_authors" value="${i}" />
						</li>					
					% endfor	

					% for count, i in enumerate(range(3)):
						<li><input type="text" name="registration_abstract_authors"/></li>
					% endfor
					
						<li>
							<input type="text" name="registration_abstract_authors"/> <input class="e2-abstract-addauthors" type="button" value="+ More authors" />
						</li>

					</ul>
				</td>
			</tr>

			<tr>
				<td>PIs:</td>
				<td>
					<ul class="e2l-nonlist">
					    % for pi in (abstract.get('name_pis_string') or []):
					        <li>
					            % if pi in faculty:
					                ${forms.select('name_pis_string', faculty, value=pi)}
					            % else:
					                ${forms.text('name_pis_string', value=pi)}
					            % endif
					        </li>
					    % endfor
                        <li>${forms.select('name_pis_string', faculty)}</li>
                        <li>${forms.select('name_pis_string', faculty)}</li>
                        <li>${forms.text('name_pis_string')} <span class="e2l-small">(Others)</span></li>
					</ul>
				</td>
			</tr>

			<tr><td colspan="2"><hr/></td></tr>

			<tr>
				<td>Abstract</td>
				<td>
					<p>
						Please carefully check formatting of any text imported from Microsoft Word. <br />
						<em>*single asterisks*</em> for italics, <strong>__double underscores__</strong> for bold<br />
						superscript with caret (^): Ca^2+^ becomes Ca<sup>2+</sup><br />
						subscript with tilde (~): H~2~O becomes H<sub>2</sub>O<br />
						Copy and paste: &alpha; &beta; &gamma; &epsilon; &Delta; &theta; &lambda; &mu; &pi; &phi; &chi; &Psi; &omega; &Omega; &#8451; • ζ Å
						</ul>
					</p>
					<p><textarea required="required" class="e2-wordcount" data-max="300" rows="20" name="registration_abstract_text">${abstract.get('registration_abstract_text','')}</textarea></p>

				</td>
			</tr>
			
			% if ADMIN:
			    <tr>
			        <td>Talk?</td>
			        <td>
			            <input type="text" name="registration_presentation" value="${abstract.get('registration_presentation', '')}" />
			        </td>
			    </tr>
			    
			    <tr>
			        <td>Poster #</td>
			        <td>
			            <input type="text" name="registration_poster_number" value="${abstract.get('registration_poster_number', '')}">
			        </td>
			    </tr>
			% endif
			
			
		</tbody>
	</table>
</%def>



<h1>${ctxt.title}</h1>

<form method="post" action="${ctxt.root}/registration/abstract/${abstract.get('name')}/edit/">
	${abstract_edit(abstract)}
	<ul class="e2l-controls">
		<li><a href="${ctxt.root}/registration/abstract/${abstract.get('name')}/delete/">(Delete Abstract?)</a></li>
		<li><input value="Save abstract" type="submit" class="e2l-big"></li>
	</ul>
</form>
