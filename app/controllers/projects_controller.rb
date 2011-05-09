class ProjectsController < ApplicationController
  require 'csv'
  layout 'default'
  
  def generate_csv
  	@project = Project.find(params[:id])
  	content_type = 'text/csv'
  	
  	CSV::Writer.generate(output = "") do |csv|
  		csv << ["ID", "Text", "Username", "Language", "Time Zone", "Review Status", "Sentiment", "Answer1", "Answer2", "Answer3"]
  		@project.tweets.each do |tweet|
  			csv << [tweet.id, tweet.text, tweet.username, tweet.lang, tweet.time_zone, tweet.review_status, tweet.sentiment, tweet.answer1, tweet.answer2, tweet.answer3]
  		end
  	end
  	send_data(output, :type => content_type, :filename => @project.name.to_s + ".csv")
  end
  
  def export_as_csv
  	render :update do |page|
  		page.redirect_to :action => "generate_csv", :id => params[:id]
  	end
  end
    
  def mark_tweets_for_review
	@project = Project.find(params[:project_id])

  	@project.tweets.en.not_reviewed[0..250].each do |tweet|
  		tweet.update_attributes(:review_status => "for review")
  	end
  	respond_to do |format|
  		flash[:notice] = "x Tweets have been marked for review"
  		format.js do
  			render :update do |page|
  				page.reload
  			end
  		end
  	end
  end
  
  def stop_mturk_daemon
  	system("ruby mturk_daemon_control.rb stop")
  	respond_to do |format|
  		flash[:notice] = "MTurk Daemon has been stopped"
  		format.js do 
  			render :update do |page|
  				page.reload
  			end
  		end
  	end  	
  end
  
  def start_mturk_daemon
	system("ruby mturk_daemon_control.rb start")
    respond_to do |format|
		flash[:notice] = "MTurk Daemon has benn started"
        format.js do
            render :update do |page|
                page.reload
            end
        end
    end
  end
      
  def start_twitter_daemon
  	system("ruby collect_daemon_control.rb start")
  	respond_to do |format|
  		flash[:notice] = "Twitter Daemon has been started"
  		format.js do 
  			render :update do |page|
  				page.reload
  			end
  		end
  	end
  end
  
  def stop_twitter_daemon
  	system("ruby collect_daemon_control.rb stop")
  	respond_to do |format|
  		format.js do 
  			render :update do |page|
  				page.reload
  			end  			
  		end
  	end
  end
  
  def delete_all_reviewable_hits
	@hits = @@mturk.SearchHITs(:PageSize => 100)[:SearchHITsResult][:HIT]
  	@hits.each do |hit|
  		if hit[:HITStatus] == "Reviewable"
  			tweet = Tweet.find_by_hit_id(hit[:HITId])
  			if tweet != nil
  				tweet.update_attributes(:review_status => nil, :hit_url => nil)
  			end
  			@@mturk.disposeHIT(:HITId => hit[:HITId])
  		end
	end
  	flash[:notice] = "All Reviewable HITs have been removed"
	respond_to do |format|
   		format.js do
        	render :update do |page|
           		page.reload
           	end
        end
	end
  end
  
  def delete_all_pending_hits
  	  @hits = @@mturk.SearchHITs(:PageSize => 100)[:SearchHITsResult][:HIT]
	  @hits.each do |hit|
		if hit[:HITStatus] == "Assignable"
			tweet = Tweet.find_by_hit_id(hit[:HITId])
			if tweet != nil
				tweet.update_attributes(:review_status => nil, :hit_url => nil)
			end
		  	@@mturk.disableHIT(:HITId  => hit[:HITId])
		end
	  end
	 flash[:notice] = "All Pending HITs have been removed"
  	 respond_to do |format|
        format.js do
            render :update do |page|
                page.reload
            end
        end
  	 end
  end
  
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.all
    @hits = []
    result = @@mturk.SearchHITs(:PageSize => 100)[:SearchHITsResult][:HIT]
    if result.class.to_s == "Hash"
    	result = [result]
    end
	if result != nil
		result.each do |hit|
	        @hits << {:hitid => hit[:HITId], :status => hit[:HITStatus]}
		end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])
	
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
      	#restart the daemon
		system("ruby collect_daemon_control.rb restart")
        format.html { redirect_to(@project, :notice => 'Project was successfully created.') }
        format.xml  { render :xml => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        system("ruby collect_daemon_control.rb restart")
        format.html { redirect_to(@project, :notice => 'Project was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    system("ruby collect_daemon_control.rb restart")
    
    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end
end
