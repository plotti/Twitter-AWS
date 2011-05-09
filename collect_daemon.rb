require "rubygems"
require "sequel"
require "tweetstream"
require "logger"
require 'language_detector'

path = File.dirname(File.expand_path(__FILE__))
log = Logger.new(path + "/" + 'collect_tweets.log')

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def red(text); colorize(text, 31); end
def green(text); colorize(text, 32); end

#Get all the projects from the DB
DB = Sequel.connect(:adapter=>'mysql', :host=>'localhost', :database=>'crowd_development', :user=>'root', :password=>'GW4Mch7i')
projects = DB[:projects]
tweets = DB[:tweets]

#Language Detector
d = LanguageDetector.new

keyword_project_list = []

@client = TweetStream::Client.new('plotti','wrzesz')

@client.on_delete do |status_id, user_id|
 log.error "Tweet deleted"
end

@client.on_limit do |skip_count|
 log.error "Limit exceeded"
end

#prepare keyword list
projects.each do |project|
  keyword_project_list << { :project_id => project[:id], :keywords => [project[:keyword1],project[:keyword2],project[:keyword3]].delete_if{|x| x==""} }
end

keywords = keyword_project_list.collect{|k| k[:keywords]}.flatten
puts keywords.to_s

@client.track(keywords.join(",")) do |status|
	keyword_project_list.each do |k|
		if k[:keywords].all? {|str| status.text.downcase.include? str}
			 tweets.insert(
			     :text => status.text,
			     :username => status.user.screen_name,
			     :created_at => status.created_at,
			     :lang => d.detect(status.text),
			     :time_zone => status.user.time_zone,
			     :guid => status.id_str,
			     :created_at => Time.now, 
				 :project_id => k[:project_id]
		     )
			#puts status.to_yaml.to_s
			#puts "[" + green("Project: " + k[:project_id].to_s)+ "]" + "[#{status.user.screen_name}] #{status.text}"
			
		end
	end    
end
