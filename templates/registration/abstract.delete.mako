<%inherit file="/page" />

<%namespace name="buttons" file="/buttons"  /> 
<%namespace name="abs" file="/registration/abstract.edit"  /> 

<h1>${ctxt.title}</h1>

${abs.abstracts_view([abstract])}

<form method="post" action="${ctxt.root}/registration/abstract/${abstract.get('name')}/delete/">
	<input type="hidden" name="confirm" value="True" />
	<ul class="e2l-controls"><li><input value="Confirm Deletion" type="submit" class="e2l-big"></li></ul>
</form>