[![Maintainability](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/maintainability)](https://codeclimate.com/github/codeclimate/codeclimate/maintainability)
[![Build Status](https://travis-ci.org/armandofox/audience1st.svg?branch=master)](https://travis-ci.org/armandofox/audience1st)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/test_coverage)](https://codeclimate.com/github/codeclimate/codeclimate/test_coverage)

Audience1st was written by [Armando Fox](https://github.com/armandofox) with contributions from
[Xiao Fu](https://github.com/fxdawnn),
[Wayne Leung](https://github.com/WayneLeung12),
[Jason Lum](https://github.com/jayl109),
[Sanket Padmanabhan](https://github.com/sanketq),
[Andrew Sun](https://github.com/andrewsun98),
[Jack Wan](https://github.com/WanNJ)


# This information is for developers and deployers

Perhaps you intended to [learn about Audience1st features and/or have us install and host it for you](https://armandofox.github.io/audience1st/)?

You only need the information on this page if you are deploying and maintaining Audience1st yourself.  If so, this page assumes you are IT-savvy and provides the information needed to help you get this Rails 2/Ruby 1.8.7 app deployed.

# Legacy Ruby/Rails

The app is on Rails 2.3.18 (2.3.5 with security patches) and Ruby 1.8.7.  I've been meaning to migrate it to Rails 3 and then Rails 4.  Help welcome.

But for now you'll have to get Rails 2.3.18 and Ruby 1.8.7 deployed on whatever host you want to deploy to.  I've been using Rackspace with Apache, mod_rails, and Phusion Passenger.

This is a stock Rails app, with the following exceptions/additions:

0. The task `Customer.notify_upcoming_birthdays` emails an administrator or boxoffice manager with information about customers whose birthdays are coming up soon.  The threshold for "soon" can be set in Admin > Options.

0. The task `EmailGoldstar.receive(STDIN.read)` should be invoked to consume incoming emails from Goldstar.  See the installation section on Goldstar integration, below.

# Required external integrations

You will need to create a file `config/application.yml` containing the following:

```yaml
session_secret: "30 or more random characters string"
stripe_key: "stripe public (publishable) key"
stripe_secret: "stripe private API key"
# include at most one of the following two lines - not both:
email_integration: "MailChimp"  # if you use MailChimp, include this line verbatim, else omit
email_integration: "ConstantContact" # if you use CC, include this line verbatime, else omit
# if you included one of the two Email Integration choices:
mailchimp_key: "optional: if you use Mailchimp, API key; otherwise omit this entry"
constant_contact_username: "Username for CC login, if using CC"
constant_contact_password: "password for CC login, if using CC"
constant_contact_key: "CC publishable part of API key"
constant_contact_secret: "CC secret part of API key"
```

# First-time deployment

Deploy the app as you would a normal Rails app, including running the migrations to load up `schema.rb`.  Only portable SQL features are used, so although MySQL was used to develop Audience1st, any major SQL database **that supports nested transactions** should work.  (SQLite does not support nested transactions, and as such, some tests that simulate network errors during credit card processing may appear to fail if you run all the specs locally against SQLite.)

Steps to Deploy Audience1st
 
Setting up the local environment
1.      Fork the rep
2.      Clone your new repo
3.      Add a new file config/database.yml that has
test:
  adapter: sqlite3
  database: db/test.sqlite3
development:
  adapter: sqlite3
  database: db/development.sqlite3
4.      Add a new file config/application.yml that looks something like this
test:
  session_secret: [session key here]
  stripe_key: [strike key here]
  stripe_secret: [stripe secret here]
development:
  session_secret: [session key here]
  stripe_key: [strike key here]
  stripe_secret: [stripe secret here]
filling actual values where it says [some key/secret here]
5.      Create a new file config/application.yml.asc (note: this step is only necessary if you are planning to deploy to heroku or use travis/codeclimate)
a.      sudo apt-get install pwgen (or brew install pwgen)
b.      pwgen 30 1
           i. save this generated password
c.      sudo apt-get install gpg (or brew install)
d.      gpg -c -a config/application.yml
                             i. use the previously generated password when it prompts you for a password
e.      When it’s time to set up travis, you should set this generated password as a travis environment variable CCKEY
6.      Add a new file public/stylesheet/venue/default.css
a.      Go to https://www.audience1st.com/altarena/login
b.      Right-click -> inspect element
c.      Go to the sources tab
d.      altarena -> stylesheets -> venue -> default.css
e.      copy that css into the new file
7.      Add a new file public/stylesheet/venue/altarena_banner.png
a.      This file is needed for the tests to pass but it doesn’t matter what the image actually is. Maybe a picture of your cat?
8.      Install sqlite3 and dependencies
9.      Install phantomjs
a.      For Mac: brew install phantomjs
b.      For Windows Bash Subsystem: phantomjs will not install correctly. Windows subsystem users in our group were forced to use a ubuntu vm for this project to get tests to pass
c.      For Ubuntu:  the apt-get repo will not work
                                                    i. Go here https://github.com/teampoltergeist/poltergeist and scroll down to the section on phantomjs to get the 32-bit or 64-bit binaries
                                                   ii. Untar the file using: tar xvjf file.tar.bz2
                                                  iii. Rename file to:  .phantomjs
                                                  iv. Move it to home with: mv .phantomjs to ~/
                                                   v. Add it to path with:
1. echo 'export PATH="$HOME/.phantomjs/bin:$PATH"' >> ~/.bashrc
2. exec $SHELL
10.   go to the audience1st folder and run basic rails startups
a.      bundle install
b.      bundle exec rake db:setup
11.   Celebrate!
 
Setting up Heroku

Go to your branch folder
run heroku create
If not pushing master branch, run git push (remote name for heroku) (branch name):master 
You need to switch the database, since sqlite does not work with heroku. Postgres currently doesn’t work due to a bug in the schema, may change later. We used mysql2 to deploy. You need to add the following lines into your gemfile (you may have to change the version #):

group :production do
  gem 'mysql2', '~> 0.3.18'
end

You also need to add a mysqladdon for heroku. We used cleardb. Note that if you use cleardb’s free plan, there is a query limit. You may have to wait a few hours after deploying to actually use the app. 
Your database_url config var needs to be correct in order to work. Go to reveal config vars in heroku console, you should see CLEARDB_DATABASE_URL mysql://somestring. 
Make a new variable called DATABASE_URL mysql2://samestring.
You also need to put in values for session_secret, stripe_key, stripe_secret, RAILS_ENV, RACK_ENV, and KEY
Run the following command to setup the database:
heroku run rake db:setup --remote (heroku remote name)
If you get an error #500, you need to restart your dynos. 
Congrats, it should work now. 


There should be a few special users, including the administrative user `admin@audience1st.com` with password `admin`.

The app should now be up and running; login and change the administrator password.  Later you can designate other users as administrators.

# Integration with Goldstar™

See the documentation on how Goldstar integration is handled in the administrator UI.

The way Goldstar works is they send your organization an email containing both the will-call list as a human-readable attachment (spreadsheet or PDF) and a link to download an XML representation of the will-call list.

Thus there are two ways you can get Goldstar will-call info for each performance into Audience1st:

1. You manually download the appropriate XML file, then use the Import mechanism in the Audience1st GUI

2. You arrange to forward a copy of Goldstar's emails to Audience1st.  Audience1st will parse the email to find the download URL, download the XML list, and parse it itself.

To support scenario 2, you must be able to configure your email system so that email received in a particular mailbox is piped to a program.  Arrange for any Goldstar emails to be fed to the following command line:

`RAILS_ENV=production $APP_ROOT/script/runner 'EmailGoldstar.receive(STDIN.read)'`

Whenever an email is fed to this task, it will eventually generate a notification email to an address specified in Admin > Options notifying someone of what happened.  If the email was a valid Goldstar will-call list, the notification will usually say "XX customers added to will-call for date YY".  If it was not a valid Goldstar will-call list, the notification will say something like "It didn't look like a will-call list, so I ignored it."


