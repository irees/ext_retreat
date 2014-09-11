<%!
import datetime
import emen2.db.config
%>

<%inherit file="/layout" />

<%block name="css_inline">
	${parent.css_inline()}

    ul {
        padding-left:20px;
    }

    p, table p {
        margin-top:10px;
        margin-bottom:10px;
		text-align: justify;
    }
    
    th, td {
        padding:10px;
        vertical-align:top;
    }
    
    .e2l-big {
        font-size:14pt;
    }

	h1 {
	    margin-top: 20px;
	    margin-bottom: 10px;
		font-size:18pt;
		border-bottom:solid 1px #ccc;
	}

	hr {
		width:80%;
		color:#f0f0f0;
	}

	.retreat-signup td:first-child {
		text-align:right;
		width:200px;
	}
	
	table {
	    width: 100%;
	}
	
	textarea {
	    width: 100%;
	}
	
	.retreat-smallcaps {
	    font-variant:small-caps;
	}
	
	#container {
		width: 800px;
		margin-left: auto;
		margin-right: auto;
		padding-bottom: 100px;
	}
</%block>


<%block name="js_ready">
	${parent.js_ready()}
	$('.e2-wordcount').WordCount();
	$('.e2-abstract-addauthors').click(function() {
		var li = '<li><input type="text" name="registration_abstract_authors"/></li>';
		$(this).parent('li').before(li);
		$(this).parent('li').before(li);
		$(this).parent('li').before(li);
	});
	$('.e2-abstract-addpis').click(function() {
		var li = '<li><input type="text" name="name_pis_string"/></li>';
		$(this).parent('li').before(li);
		$(this).parent('li').before(li);
		$(this).parent('li').before(li);
	});	
</%block>


<%block name="header">

	<div style="padding:10px">

		<h1 style="border-bottom:none;text-align:center">
			<a href="${ctxt.root}/">
			The Verna &amp; Marrs McLean Department<br /> of Biochemistry &amp; Molecular Biology<br /> and<br /> The Department of Pharmacology <br /> Research Conference - ${emen2.db.config.get('ext_retreat.year')}
			</a>
		</h1>

		<p style="text-align:center">
			${" and ".join(map(lambda x:datetime.datetime.strptime(x, '%Y-%m-%d').strftime('%A, %B %d, %Y'), emen2.db.config.get('ext_retreat.dates', [])))} <br />
			<a href="${emen2.db.config.get('ext_retreat.site_link')}">
				${emen2.db.config.get('ext_retreat.site_name')}
			</a> <br />
		</p>

	</div>

</%block>


## No tabs..
<%block name="tabs" />

## Ughgh..
<ul class="e2-alert">
% if ERRORS:
    % for e in ERRORS:
        <li>Error: ${e}</li>
    % endfor
% endif
</ul>

${next.body()}