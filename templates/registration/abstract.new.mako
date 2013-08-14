<%inherit file="/page" />

<%namespace name="buttons" file="/buttons"  /> 
<%namespace name="abs" file="/registration/abstract.edit"  /> 


<h1>${ctxt.title}</h1>

<form method="post" action="${ctxt.root}/registration/abstract/new/">
	${abs.abstract_edit(abstract)}
	<ul class="e2l-controls"><li><input value="Submit Abstract" type="submit" class="e2l-big"></li></ul>
</form>