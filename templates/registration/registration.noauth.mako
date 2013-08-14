<%inherit file="/page" />

<%namespace name="buttons" file="/buttons"  /> 
<%namespace name="login" file="/auth/login"  /> 

<p>Welcome to the Baylor College of Medicine Biochemistry &amp; Molecular Biology and Department of Pharmacology Research Conference 2012.</p>

<br />

<form action="${ctxt.root}/registration/new/" method="get">
	<p style="text-align:center">
		<input type="submit" class="e2l-big" value="Click here to register for the 2012 conference" />
	</p>
</form>

<%call expr="buttons.singlepage('Returning users')">

	If you have already started a registration for this year's conference, you may login (using the email address and password you supplied during registration) to edit your registration details and submit abstracts.

	${login.login()}

</%call>
