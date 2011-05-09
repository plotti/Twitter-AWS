require 'rubygems'
require 'sequel'
require 'ruby-aws'
require 'amazon/webservices/mturk/question_generator'
require 'time'
require 'builder'

#Initialize MTurk
include Amazon::WebServices::MTurk
@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Config => File.join( File.dirname(__FILE__), '/config/mturk.yml' )

#Get all the projects from the DB its preset to development mode
DB_CONFIG = YAML.load_file("config/database.yml")
DB = Sequel.connect(:adapter=>DB_CONFIG["development"]["adapter"], :host=>'localhost', :database=>DB_CONFIG["development"]["database"], 
					:user=>DB_CONFIG["development"]["username"], :password=>DB_CONFIG["development"]["password"])
projects = DB[:projects]
tweets = DB[:tweets]


def createHit(tweet,project_questions,quality)
  title = "Please answer those questions:"
  desc = "Tweet: #{tweet} . Please answer the questions regarding this tweet:"
  keywords = "twittter, content, sentiment"
  numAssignments = 1
  rewardAmount = 0.01 # 1 cents

  qualReq = { :QualificationTypeId => "000000000000000000L0",
              :Comparator => 'GreaterThan',
              :IntegerValue => quality.to_s }
                              
  hitType = @mturk.registerHITType( :Title => "Human Tweets Tagging",
                    :Description => "Help us answer three short questions: #{project_questions.to_s}  about a tweet.",
                    :Reward => { :Amount => rewardAmount, :CurrencyCode => 'USD' },
                    :AssignmentDurationInSeconds => "30",
                    :AutoApprovalDelayInSeconds => "5000",
					:QualificationRequirement => qualReq,
                    :Keywords => keywords )
  
  hitTypeId = hitType[:HITTypeId]

  question = ""
  x = Builder::XmlMarkup.new(:target => question, :indent => 1)
  x.instruct!
  x.QuestionForm("xmlns" => "http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2005-10-01/QuestionForm.xsd"){
   	x.Overview {
	   	x.Text "Please analyze the following tweet and try to answer the following questions."
	   	x.Text "Please make sure to read the following additional informations, if you are new to this task:"
	   	x.List{
	   		x.ListItem "A tweet is a status message publicly broadcasted to from a twitter user to other users on twitter"
	   		x.ListItem "If a tweet does not make sense to you please skip that task."
	   		x.ListItem "If a tweet is too short to be analyzed please skip that task."
	   		x.ListItem "Sometimes a tweet contains a link. It can help to  click that link in order to make sense of the tweet message"
	   		x.ListItem "If you don't know the company or product you will have problems to answer the questions"
	   		}
	   	x.Text "Tweet to be analyzed:#{tweet}"
	   	#x.FormattedContent{
	   	#		x.cdata! "<h1>Tweet to be analyzed:#{tweet}<h1>"
	   	#	}
	}
	x.Question {
		x.QuestionIdentifier "sentiment"
		x.IsRequired true
		x.QuestionContent {
			x.Text "Is the sentiment in the tweed positive, neutral, or negative? - Please specify whether the tweed expresses positve, neutral or negative feelings"
		}
		x.AnswerSpecification{
			x.SelectionAnswer {
            	x.Selections {
                	x.Selection {
                    	x.SelectionIdentifier "positive"
                        x.Text "Positive"
                    }
                    x.Selection {
                    	x.SelectionIdentifier "negative"
                    	x.Text "Negative"
                    }
                    x.Selection {
                    	x.SelectionIdentifier "neutral"
                    	x.Text "neutral"
                    }
				}
			}
		}
	}
	i = 0
   	project_questions.each do |pq|
		i += 1
	  	x.Question {
    		x.QuestionIdentifier "question#{i}"
			x.IsRequired true
			x.QuestionContent {
    	  		x.Text pq
    		}
	    	x.AnswerSpecification {
    	  		x.SelectionAnswer {
    	  			x.Selections{
    	  				x.Selection{
    	  					x.SelectionIdentifier "Yes"
    	  					x.Text "Yes"
    	  				}
    	  				x.Selection{
    	  					x.SelectionIdentifier "No"
    	  					x.Text "No"
    	  				}
    	  			}
    	  		}
    		}
	  	}
	end	
  }

  result = @mturk.createHIT( :Title => title,
                    :Description => desc,
                    :MaxAssignments => numAssignments,
                    :Reward => { :Amount => rewardAmount, :CurrencyCode => 'USD' },
                    :Question => question,
					:HITTypeId => hitTypeId,
                    :Keywords => keywords
                    )

  puts "Created HIT: #{result[:HITId]}"
  puts "Url: #{getHITUrl( result[:HITTypeId] )}"
  return result
end

def getHITUrl( hitTypeId )
  if @mturk.host =~ /sandbox/
    "http://workersandbox.mturk.com/mturk/preview?groupId=#{hitTypeId}" # Sandbox Url
  else
    "http://mturk.com/mturk/preview?groupId=#{hitTypeId}" # Production Url
  end
end

def disposeAllHits
        hitids = @mturk.GetReviewableHITs[:GetReviewableHITsResult][:HIT]
		if hitids != nil
			hitids.collect{|h| h[:HITId]}.each do |id|
    	       @mturk.disposeHIT(:HITId => id)
        	end
		end
end

# Check to see if your account has sufficient funds
def hasEnoughFunds?
  available = @mturk.availableFunds
  puts "Got account balance: %.2f" % available
  return available > 0.055
end

################  MAIN ##########################

do_once = true
while true do 
	sleep(1)
	time = Time.now.sec
    if time % 10  == 0 && do_once

		puts "Checking for out"
		#Check for tweets that need to be sent out.
		tweets.each do |tweet|
			if tweet[:review_status] == "for review"
				project = projects.filter(:id => tweet[:project_id]).first
				result = createHit(tweet[:text],[project[:question1],project[:question2],project[:question3]].flatten,project[:quality_requirement])
				tweets.filter(:id => tweet[:id]).update(:review_status => "pending", :hit_id => result[:HITId], :hit_url => getHITUrl(result[:HITTypeId]))
			end
		end

		puts "Checking for in"
		#Receive tweets that have been processed
		hitids = []
		result =  @mturk.GetReviewableHITs[:GetReviewableHITsResult][:HIT]
		if result.class.to_s == "Hash"
			hitids << result
		elsif result.class.to_s != "NilClass"
			hitids = result
		end
		if hitids != []
			hitids.collect{|h| h[:HITId]}.each do |id|
				assignment = @mturk.getAssignmentsForHIT(:HITId => id)[:Assignment]
				if assignment != nil
					if (assignment[:AssignmentStatus] == "Submitted") or (assignment[:AssignmentStatus] == "Approved")
						hit = @mturk.getHIT(:HITId => id)
						puts "For Hit #{id} with status #{hit[:HITStatus]} found assignments with status #{assignment[:AssignmentStatus]}"
						result = @mturk.simplifyAnswer(assignment[:Answer])
						tweets.filter(:hit_id => assignment[:HITId]).update(
							:review_status => "reviewed",
							:sentiment => result["sentiment"],
							:answer1 => result["question1"],
							:answer2 => result["question2"],
							:answer3 => result["question3"],
							:worker_id => assignment[:WorkerId]
						)
						puts "Succesfully received a response"

						#Quality Control Reject Workers that submitted the same answer
						counter = 0
						r = ""
						tweets.filter(:worker_id => assignment[:WorkerId]).each do |t|
							r_old = r
							r = t[:answer1] +  t[:answer2] + t[:answer3] + t[:sentiment]
							if r_old == r
								puts "wid: #{assignment[:WorkerId]} counter: #{counter} old r#{r_old} and new r#{r}"
								counter += 1
							end
						end
						if counter > 5
							@mturk.BlockWorker(:WorkerId => assignment[:WorkerId], :Reason => "Bad classification.Sorry")
								puts "Blocked worker #{assignment[:WorkerId]}"
							if assignment[:AssignmentStatus] != "Approved" #was already approved by timeout
								@mturk.RejectAssignment(:AssignmentId => assignment[:AssignmentId])
								puts "Rejected Assignment Counter #{counter} Worker ID #{assignment[:WorkerId]}"
							end
						else
							if assignment[:AssignmentStatus] != "Approved" #was already approved by timeout
								@mturk.ApproveAssignment(:AssignmentId => assignment[:AssignmentId])
								puts "Accepted Assignment"
							end
						end
						@mturk.disposeHIT(:HITId => id)
						puts "Disposed Hit #{id}"												
					end
				end
			end
		end

        do_once = false
    elsif time  % 10 != 0
        do_once = true
    end
end

