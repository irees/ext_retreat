<%!
import collections
import jsonrpc.jsonutil
%>
<%inherit file="/page" />

<%namespace name="buttons" file="/buttons"  /> 

<%block name="css_inline">
    ${parent.css_inline()}
	table.results td:first-child,
	table.results th:first-child {
		border-right: solid 2px black;
		width: 50px;
	}

	table.results th {
		border-bottom: solid 2px black;
	}
	
	table.results td,
	table.results th {
		padding: 5px;
	}
</%block>

<h1>
	${ctxt.title} (${len(results)}  scores)
	<a class="e2l-label" href="${ctxt.reverse('Judging/new')}">${buttons.image('edit.png')} New Score</a>
</h1>

<%
scores = [result.get('judging_ranked_score', []) for result in results]

# Steve's suggestion
rs = collections.defaultdict(int)
posters = set()
for score in scores:
	while r:
		p = r.pop(0)
		posters.add(p)
		for i in r:
			print "%s beats %s"%(p,i)
			rs[(p,i)] += 1

print "Matchups:"
print rs

paired = set()
for (k,v) in rs.keys():
	if rs.has_key((k,v)) and rs.has_key((v,k)):
		print "Pairwise %s and %s"%(k,v)
		paired.add(k)
		paired.add(v)	
		print rs[(k,v)]
		print rs[(v,k)]
		
print paired
	
def s(x,y):
	#if rs.get((x,y)) == None or rs.get((y,x)) == None:
	#	return 0
	return cmp(rs[(x,y)], rs[(y,x)])

print "Sorted?"
print sorted(posters, cmp=s, reverse=True)


# Original
scores2 = collections.defaultdict(list)
for result in results:
	score = result.get('judging_ranked_score', [])
	if len(score) < 3:
		continue
	for poster, value in zip(score, weights[len(score)-1]):
		scores2[poster].append(value)

avg = lambda y:(sum(y[1])/len(y[1]))
%>

<table class="e2l-kv e2l-shaded retreat-results" cellpadding="0" cellspacing="0">
	<thead>
		<tr>
			<th>Rank</th>
			<th>Poster #</th>
			<th>Judged by</th>
			<th style="width:auto">Raw</th>
			<th>Average</th>
		</tr>
	</thead>
	
	<tbody>

		% for count, (k, v) in enumerate(sorted(scores2.items(), key=avg)):
			<tr>
				<td>${count+1}</td>
				<td>${k}</td>
				<td>${len(v)}</td>
				<td>${', '.join(map(str, v))}</td>
				<td>${sum(v)/len(v)}</td>
			</tr>
		% endfor

	</tbody>
</table>

<h1>Raw results</h1>
<ul>
% for result in results:
    ## ${result.name}: 
    <li>${result.get('judging_ranked_score')}</li>
% endfor
</ul>

<h1>JSON</h1>

${jsonrpc.jsonutil.encode(scores)}
