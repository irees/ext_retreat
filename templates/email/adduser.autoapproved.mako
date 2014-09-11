<%!
import datetime
import emen2.db.config
def fmt_date(x):
	return datetime.datetime.strptime(x, '%Y-%m-%d').strftime('%A, %B %d, %Y')

%>From: ${from_addr}
To: ${to_addr}
Cc: ${from_addr}
Subject: ${TITLE} Registration

${to_addr}:

Your ${TITLE} registration has been received and approved.

Here are your account details:
${uri}
Username: ${to_addr}

You may login to edit your registration and submit an abstract. 
You must submit an abstract if you are giving a talk or presenting a poster. 
All 3rd year and above students are required to give a talk or present a poster.

Maximum poster size is 4 feet wide by 4 feet high.

Please note that changes to your registration must be completed by ${fmt_date(emen2.db.config.get('ext_retreat.deadline_registration'))}.

Abstracts will be accepted until ${fmt_date(emen2.db.config.get('ext_retreat.deadline_abstracts'))}.

Please contact me if you have any difficulties.

Thank you,

Ruth Reeves
${TITLE} Administrator
${from_addr}
${uri}
