# $Id: help.py,v 1.1 2011/07/06 21:12:16 edwlan Exp $
import time
import hashlib
import random
import csv

from emen2.web.view import View

faculty = [
    "Atassi, M. Zouhair",
    "Barth, Patrick",
    "Chan, Lawrence C. B.",
    "Chan, Pui-Kwong",
    "Chiu, Wah",
    "Danesh, Farhad R.",
    "De La Garza, Richard",
    "Donoviel, Dorit B.",
    "Entman, Mark L.",
    "Fann, William Edwin",
    "Gilbert, Hiram F.",
    "Golding, Ido",
    "He, Xiangwei",
    "Kim, Choel",
    "Kosten, Thomas",
    "Kuspa, Adam",
    "Lichtarge, Olivier",
    "Ludtke, Steve",
    "Ma, Jianpeng",
    "Matzuk, Martin",
    "Morrisett, Joel D.",
    "Newton, Thomas",
    "Palzkill, Timothy",
    "Pan, Xuewen",
    "Peters, Christopher",
    "Pool, James L.",
    "Prasad, B.V.V.",
    "Qin, Jun",
    "Quiocho, Florante A.",
    "Reddy, Ramachandra R.",
    "Rosenberg, Susan M.",
    "Sazer, Shelley",
    "Schmid, Michael F.",
    "Sokac, Anna Marie",
    "Song, Yongcheng",
    "Songyang, Zhou",
    "Sreekumar, Arun",
    "Taylor, Addison A.",
    "Tolias, Kimberley R.",
    "Tsai, Francis T. F.",
    "Wakil, Salih J.",
    "Wang, Jin",
    "Wang, Jue",
    "Wang, Qinghua",
    "Wensel, Theodore G.",
    "Westbrook, Thomas F.",
    "Wilson, John",
    "Yeoman, Lynn",
    "Zechiedrich, Lynn",
    "Zhang, Pumin",
    "Zhou, Ming",
    "Zhou, Zheng",
    "Zhang, Xiang",
    "Schiff, Rachel"
]


def nodeleted(r):
    return filter(lambda x:not x.get('deleted'), r)


@View.register
class Registration(View):
    @View.add_matcher(r'^/$', r'^/home/$', r'^/registration/$')
    def common(self):
        self.title = "Registration"
        self.template = "/registration/registration.main"

        self.ctxt['faculty'] = sorted(faculty)
        self.ctxt['ERRORS'] = []

        # Anonymous users get the login page
        username = self.db.auth.check.context()[0]
        user = self.db.user.get(username)
        if not username or username=='anonymous':
            self.template = "/registration/registration.noauth"
            return
        
        children = self.db.rel.children(user.record, recurse=-1)
        children_recs = self.db.record.get(children)
            
        # Get the registration and abstract
        abstracts = filter(lambda x:x.rectype == 'registration_abstract', children_recs)
        self.ctxt['abstracts'] = abstracts
        
        registrations = filter(lambda x:x.rectype == 'registration', children_recs)
        if registrations:
            self.ctxt['registration'] = registrations[-1]
        else:
            self.ctxt['registration'] = {}

    @View.add_matcher(r'^/registration/new/$')
    def register_new(self, **kwargs):
        self.common()
        self.title = "New Registration"
        self.template = "/registration/registration.new"
        self.ctxt['kwargs'] = kwargs

        if not self.request_method == 'post':
            return

        kwargs['childrecs'] = [kwargs.pop('childrec')]

        # Add the new user account.
        email = kwargs.get('email','')
        password = kwargs.pop('password','')
        password2 = kwargs.pop('password2', '')

        # Validate the user account
        if len(password) < 6:
            self.ctxt['ERRORS'].append('Password must be at least 6 characters long.')

        elif password != password2:
            self.ctxt['ERRORS'].append('The two passwords did not match.')

        # Check for errors before continuing
        if self.ctxt['ERRORS']:
            return
        
        try:
            user = self.db.newuser.new(email=email, password=password)
            user.setsignupinfo(kwargs)
            self.db.newuser.request(user)
        except Exception, e:
            self.ctxt['ERRORS'].append('There was an error processing your request: %s'%e)
            return

        self.redirect(
            self.ctxt.root, 
            title="Account successfully created", 
            content="Your account has been created; please check %s for a confirmation message. If you plan on giving a talk or poster, please login and submit your abstract."%user.email, 
            auto=False)

    @View.add_matcher(r'^/profile/edit/$')
    def profile_edit(self, **kwargs):
        self.common()
        self.title = "Edit profile"
        self.template = "/registration/profile.edit"

        if self.request_method == 'post':
            rec = self.db.record.put(kwargs)
            self.redirect(
                self.ctxt.root, 
                title="Profile saved", 
                content="Your profile has been saved.",
                auto=False)        

    @View.add_matcher(r'^/registration/edit/$')
    def register_edit(self, **kwargs):
        self.common()
        self.title = "Edit registration"
        self.template = "/registration/registration.edit"

        if self.request_method == 'post':
            rec = self.db.record.put(kwargs)
            self.redirect(
                self.ctxt.root, 
                title="Registration details saved", 
                content="Your registration details have been saved.",
                auto=False)        
        
    @View.add_matcher(r'^/registration/abstract/new/$')
    def abstract_new(self, **kwargs):
        self.common()
        self.title = "New Abstract"
        self.template = "/registration/abstract.new"
    
        username = self.db.auth.check.context()[0]
        user = self.db.user.get(username)
        abstract = self.db.record.new(rectype='registration_abstract')
        abstract.parents.add(user.record)
        self.ctxt['abstract'] = abstract

        if self.request_method == 'post':
            abstract.update(kwargs)
            length = len(abstract.get('registration_abstract_text', '').split(" "))
            if length  > 350:
                self.ctxt['ERRORS'].append('Abstract too long, limit is 300 words: %s'%length)
                return                
            self.db.record.put(abstract)
            self.redirect(
                self.ctxt.root, 
                title="Abstract saved", 
                content="Your abstract been saved.",
                auto=False)        
                    
    @View.add_matcher(r'^/registration/abstract/(?P<name>\w+)/edit/$')
    def abstract_edit(self, name, **kwargs):
        self.common()
        self.title = "Edit Abstract"
        self.template = "/registration/abstract.edit"               
        
        abstract = self.db.record.get(name, filt=False)
        self.ctxt['abstract'] = abstract
        
        if self.request_method == 'post':
            abstract.update(kwargs)
            length = len(abstract.get('registration_abstract_text', '').split(" "))
            if length  > 350:
                self.ctxt['ERRORS'].append('Abstract too long, limit is 300 words: %s'%length)
                return                
            self.db.record.put(abstract)
            self.redirect(
                self.ctxt.root, 
                title="Abstract saved", 
                content="Your abstract been saved.",
                auto=False)      
                
    @View.add_matcher(r'^/registration/abstract/(?P<name>\w+)/delete/$')
    def abstract_delete(self, name, **kwargs):
        self.common()
        self.title = "Delete Abstract"
        self.template = "/registration/abstract.delete"             

        abstract = self.db.record.get(name, filt=False)
        self.ctxt['abstract'] = abstract

        if self.request_method == 'post' and kwargs.get('confirm'):
            self.db.record.hide(abstract.name)
            self.redirect(
                self.ctxt.root, 
                title="Abstract saved", 
                content="Your abstract been deleted.",
                auto=False)      


@View.register
class RegistrationAdmin(View):
    @View.add_matcher(r'^/registration/admin/registrants/$')
    def registration_admin(self, **kwargs):
        self.title = 'Registrants'
        self.template = '/registration/registrants'
        regnames = self.db.record.findbyrectype('registration')
        registrations = nodeleted(self.db.record.get(regnames))
        abstracts = nodeleted(self.db.record.get(self.db.record.findbyrectype('registration_abstract')))
        users = self.db.user.get(self.db.user.filter())
        self.ctxt['regnames'] = regnames
        self.ctxt['users'] = users
        self.ctxt['registrations'] = registrations
        self.ctxt['abstracts'] = abstracts

    @View.add_matcher(r'^/registration/admin/abstracts/$')
    def abstracts_view(self, **kwargs):
        self.registration_admin(**kwargs)
        self.template = '/registration/abstracts'
        self.title = 'Preview Abstracts'

    @View.add_matcher(r'^/registration/admin/registrants/csv/.+$')
    def registration_csv(self, **kwargs):
        self.registration_admin(**kwargs)
        self.template = '/registration/registrants.csv'
        self.headers['Content-Type'] = 'text/csv'

    @View.add_matcher(r'^/registration/admin/abstracts/html/.+$')
    def abstracts_html(self, pageoffset=1, **kwargs):
        self.registration_admin(**kwargs)
        self.template = '/registration/abstracts.html'
        self.ctxt['pageoffset'] = int(pageoffset)

    @View.add_matcher(r'^/registration/admin/abstracts/save/$')
    def abstracts_save(self, **kwargs):
        for k,v in kwargs.items():
            v['name'] = k
        if self.request_method == 'post':
            self.db.record.put(kwargs.values())
            self.simple('Saved')


@View.register
class Judging(View):
    @View.add_matcher(r'/registration/judging/$')
    def main(self):
        self.template = '/registration/judging.main'
        self.title = 'Judging Correspondence'
        
        # Get all the items...
        regnames = self.db.record.findbyrectype('registration')
        registrations = nodeleted(self.db.record.get(regnames))
        abstracts = nodeleted(self.db.record.get(self.db.record.findbyrectype('registration_abstract')))
        abstracts = filter(lambda x:x.get('registration_presentation') != 'talk', abstracts)

        users = self.db.user.get(self.db.user.filter())
        self.ctxt['regnames'] = regnames
        self.ctxt['users'] = users
        self.ctxt['registrations'] = registrations
        self.ctxt['abstracts'] = abstracts
        
    @View.add_matcher(r'/registration/judging/results/$')
    def results(self):
        self.template = '/registration/judging.results'
        self.title = 'Judging results'
        self.ctxt['results'] = nodeleted(self.db.record.get(self.db.record.findbyrectype('judging_result')))
        weights = [
            [],
            [],
            [1.5,  3.0,  4.5],
            [1.2,  2.4,  3.6,  4.8],
            [1.0,  2.0,  3.0,  4.0,  5.0 ]
        ]
        self.ctxt['weights'] = weights

    @View.add_matcher(r'/registration/judging/new/$')
    def new(self, judging_ranked_score=None, **kwargs):
        self.template = '/registration/judging.new'
        self.title = 'New judging score'
        
        judging_ranked_score = judging_ranked_score or []
        self.ctxt['judging_ranked_score'] = judging_ranked_score

        if self.request_method != 'post':
            return

        # Get the valid poster #'s
        abstracts = nodeleted(self.db.record.get(self.db.record.findbyrectype('registration_abstract')))
        abstracts = filter(lambda x:x.get('registration_presentation') != 'talk', abstracts)
        valid_posters = set([x.get('registration_poster_number') for x in abstracts])
        # print "valid_posters:", valid_posters

        try:
            filtered = map(int, filter(None, judging_ranked_score))
            
            if len(set(filtered)) != len(filtered):
                raise ValueError, 'You entered a poster more than once'
            
            if len(set(filtered)) < 3:
                raise ValueError, 'You must enter at least 3 posters'
            # if set(filtered) - valid_posters:
            #    raise ValueError, "Invalid poster #'s: %s"%', '.join(map(str, set(filtered) - valid_posters))

        except Exception, e:
            self.notify(str(e), error=True)
            
        else:
            newrec = self.db.record.new(rectype='judging_result')
            newrec['judging_ranked_score'] = judging_ranked_score
            rec = self.db.record.put(newrec)
            self.notify('Saved score: %s'%(', '.join(map(str, rec.get('judging_ranked_score', [])))))
            # Reset the form
            self.ctxt['judging_ranked_score'] = []
            


__version__ = "$Revision: 1.1 $".split(":")[1][:-1].strip()
