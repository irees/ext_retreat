<%inherit file="/page" />

<%namespace name="buttons" file="/buttons"  /> 

<%block name="css_inline">
    ${parent.css_inline()}
	
	.retreat-judging-form {
	    width:400px;
	    margin-left:auto;
	    margin-right:auto    
	}
    
    .retreat-judging-form li {
        margin:10px;
    }
    
	.retreat-judging-form input[type=number] {
		font-size:24pt;
	}
</%block>

<h1>${ctxt.title}</h1>

<%
while len(judging_ranked_score) < 5:
	judging_ranked_score.append('')

%>

<form method="post" action="${ctxt.reverse('Judging/new')}">

    <ul class="e2l-nonlist retreat-judging-form">
		<li>
		    <input type="number" value="${judging_ranked_score[0]}" name="judging_ranked_score" autocomplete="off" required placeholder="1st" />
		</li>
		<li>
		    <input type="number" value="${judging_ranked_score[1]}" name="judging_ranked_score" autocomplete="off" required placeholder="2nd" />
		</li>
		<li>
		    <input type="number" value="${judging_ranked_score[2]}" name="judging_ranked_score" autocomplete="off" required placeholder="3rd" />
		</li>
		<li>
		    <input type="number" value="${judging_ranked_score[3]}" name="judging_ranked_score" autocomplete="off" placeholder="4th" />
		</li>
		<li>
		    <input type="number" value="${judging_ranked_score[4]}" name="judging_ranked_score" autocomplete="off" placeholder="5th" />
		</li>
	</ul>
		
    <ul class="e2l-actions">
		<input type="submit" value="Save" class="e2l-big" />
    </ul>

</form>
