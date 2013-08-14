import random
import json

JUDGECOUNT = 5
MINRATING = 0
MAXRATING = 5

class User(object):
	def __init__(self, name=None, institution=None, pi=None, roles=None, count=0):
		self.name = name
		self.institution = institution
		self.pi = pi or self.name
		self.roles = roles or []
		self.count = count
		self.judges = []
		self.scores = {}

	def __repr__(self):
		return str(self.name)
		
	def addscore(self, judge, result):
		self.scores[judge.name] = Score(judge, result)	
		
	def avgscore(self):
		scores = [i.total()/float(MAXRATING) for i in self.scores.values()]
		return sum(scores) / float(len(scores))
		
	def load(self, j):
		return
	
	def dump(self):
		return self.__dict__
		
class Score(object):
	def __init__(self, judge, result):
		self.judge = judge.name
		self.scores = result or []

	def total(self):
		return sum(self.scores)

	def load(self, j):
		return

	def dump(self):
		return self.__dict__

def match(presenter, judge):
	if presenter.name != judge.name and presenter.pi != judge.pi:
		return True
	return False

users = set()

# Presenters
users.add(User(name='Michelle Darrow', pi='Wah Chiu', roles=['Presenter', 'Judge']))
users.add(User(name='Edward Langley', pi='Wah Chiu', roles=['Presenter']))
users.add(User(name='Bernard Francois', pi='Francis Tsai', roles=['Presenter']))

# Judges
users.add(User(name='John Doe', pi='Lydia Kavraki', roles=['Judge']))
users.add(User(name='Francis Tsai', roles=['Judge']))
users.add(User(name='Wah Chiu', roles=['Judge']))
users.add(User(name='Lydia Kavraki', roles=['Judge']))
users.add(User(name='Aditya', pi='Peters', roles=['Judge']))
users.add(User(name='Sarah Shahmoridan', pi='Wah Chiu', roles=['Judge']))
users.add(User(name='Corey Hecksel', pi='Wah Chiu', roles=['Judge']))
users.add(User(name='Mike Evanelista', pi='Peters', roles=['Judge']))

presenters = [i for i in users if 'Presenter' in i.roles]
judges = [i for i in users if 'Judge' in i.roles]

print "Presenters:", presenters
print "Judges:", judges

# Select Judges
for p in presenters:
	print "\n== Finding judges for %s"%p
	matches = [j for j in judges if match(p,j)]
	matches = sorted(matches, key=lambda x:x.count)
	print "Found matches:", matches	
	print "Selecting %s judges at random:"%JUDGECOUNT
	for i in matches[:JUDGECOUNT]:
		i.count += 1
		print "... selected:", i, "... current count:", i.count
		p.judges.append(i)
	
# Scoring	
for p in presenters:
	print "\n== Scoring for %s"%p
	for j in p.judges:
		score = [random.randint(MINRATING,MAXRATING) for i in range(4)]
		print "...", j, ":", score
		p.addscore(j, score)
		
# Results
print "\n\n====== TOTAL SCORES ======="
for count, p in enumerate(sorted(presenters, key=lambda x:x.avgscore(), reverse=True)):
	print count+1, p, p.avgscore()
	
print "\n== Writing current state..."	
print json.dumps(list(users), default=lambda x:x.dump())
	
