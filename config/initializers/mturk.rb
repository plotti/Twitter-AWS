require 'rubygems'
require 'ruby-aws'

include Amazon::WebServices::MTurk
@@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Config => File.join( File.dirname(__FILE__), '../mturk.yml' )
