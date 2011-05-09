class TweetsController < ApplicationController
  layout 'default'

  # GET /tweets
  # GET /tweets.xml
  def index
	@project = Project.find(params[:project_id])
	if params[:for_review]
	    @tweets = @project.tweets.for_review.paginate :page => params[:page], :order => 'updated_at DESC'
	elsif params[:reviewed]
		@tweets = @project.tweets.reviewed.paginate :page => params[:page], :order => 'updated_at DESC'
	elsif params[:pending]
		@tweets = @project.tweets.pending.paginate :page => params[:page], :order => 'updated_at DESC'
	else
		@tweets = @project.tweets.paginate :page => params[:page], :order => 'updated_at DESC'
	end
	
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tweets }
    end
  end

  # GET /tweets/1
  # GET /tweets/1.xml
  def show
	@project = Project.find(params[:project_id])
    @tweet = Tweet.find(params[:id])
	
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tweet }
    end
  end

  # GET /tweets/new
  # GET /tweets/new.xml
  def new
    @tweet = Tweet.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tweet }
    end
  end

  # GET /tweets/1/edit
  def edit
    @project = Project.find(params[:project_id])
    @tweet = Tweet.find(params[:id])
  end

  # POST /tweets
  # POST /tweets.xml
  def create
    @tweet = Tweet.new(params[:tweet])

    respond_to do |format|
      if @tweet.save
        format.html { redirect_to(@tweet, :notice => 'Tweet was successfully created.') }
        format.xml  { render :xml => @tweet, :status => :created, :location => @tweet }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tweet.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tweets/1
  # PUT /tweets/1.xml
  def update
  	@project = Project.find(params[:project_id])
    @tweet = Tweet.find(params[:id])

    respond_to do |format|
      if @tweet.update_attributes(params[:tweet])
        format.html { redirect_to(project_tweet_path(@project,@tweet), :notice => 'Tweet was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tweet.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tweets/1
  # DELETE /tweets/1.xml
  def destroy
    @tweet = Tweet.find(params[:id])
    @tweet.destroy

    respond_to do |format|
      format.html { redirect_to(tweets_url) }
      format.xml  { head :ok }
    end
  end
end
