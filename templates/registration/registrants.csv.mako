<% 
import csv
import collections
import cStringIO

import jsonrpc.jsonutil
users_d = {}
for user in users:
	users_d[user.name] = user
reg_d = {}
for reg in registrations:
	reg_d[reg.name] = reg

outfile = cStringIO.StringIO()
writer = csv.writer(outfile)
header = ['Last Name',
	'First Name',
	'Email',
	'Institution',
	'Department',
	'Primary PI',
	'Secondary PI', 
	'Tshirt', 
	'Vegetarian', 
	'Employee Type',
	'Attending Thursday',
	'Attending Friday',
	'Poster or talk',
	'Hotel',
	'Gender',
	'Roommate',
	'Charge Source'
]
writer.writerow(header)

for user in users:
	urec = user.get('userrec',dict())
	regs = urec.get('children', set()) & regnames
	if not regs:
		continue
	reg = regs.pop()
	reg = reg_d.get(reg,dict())

	row = []
	row.append(urec.get('name_last'))
	row.append(urec.get('name_first'))
	row.append(user.get('email'))
	row.append(urec.get('institution'))
	row.append(urec.get('department'))
	row.append(reg.get('registration_pi'))
	row.append(reg.get('registration_pi_secondary'))
	row.append(reg.get('registration_shirtsize'))
	row.append(', '.join(reg.get('registration_mealpreferences',[])))
	row.append(reg.get('registration_type'))
	row.append('2013-10-10' in reg.get('registration_attend',[]))
	row.append('2013-10-11' in reg.get('registration_attend',[]))
	row.append(reg.get('registration_presentation'))
	row.append(reg.get('registration_accomodation'))
	row.append(reg.get('registration_gender'))
	row.append(reg.get('registration_roommate'))
	row.append(reg.get('registration_funding_source'))
	writer.writerow(row)

%>

${outfile.getvalue()}
