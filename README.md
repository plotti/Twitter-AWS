# Welcome to Twitter AWS

## Twitter AWS is a Rails application that helps you to

1. Collect tweets from the twitter garden hose for a given keyword
2. Create a set of classification criteria i.e. Is this tweet funny? Is it about a product? and so on...
3. Send out those tweets to Amazon Mechanical Turk and let crowdsource the questions
4. Review the Answers

## Getting Started

1. You will need a AWS Account with some cash on it
2. You will need the aws  gem:
  http://ruby-aws.rubyforge.org/ruby-aws/
  gem install intridea-tweetstream

## Projects

1. For each set of questions and keywords you can create a keyword. 
2. Once you have set those up there are two deamons that need to be started:
- The twitter keyword collection deamon
- The Amazon MTurk Daemon

## Daemons 

You can start the daemons from the administration console once the webserver is running. 

### Twtiter Daemon 

The Twitter Collection deamon watches the firehose for specific keywords and then adds them to the specific project

### MTurk Daemon 
1. The MTurk daemon periodically looks through the Database for jobs that have been marked for crowdcourcing.
2. If a job was marked for crowdsourcing, it sends it to mturk for tagging
3. and then periodically checks if the job has been processed yet
4. Processed jobs are reviewed and downloaded


## Quality Considerations 

When using Amazon MTurk we have some quality considerations to maintain a higher chance of getting a good job done:

a) For each project you can set a reward per job
b) For each project you can set a minimum average rating that the worker must have performed in the past
c) We reject workers that submit more than 5 times the exact same aswer for tweets and put them on a black list


## Reading up on MTURK 

You can read up more information on how MTurk works on: http://aws.amazon.com/mturk/


