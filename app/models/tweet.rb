class Tweet < ActiveRecord::Base
	REVIEW_STATUS = ["for review", "pending", "reviewed"]
	belongs_to :projects
	named_scope :for_review, :conditions => {:review_status  => 'for review'}
	named_scope :pending, :conditions => {:review_status => 'pending'}
	named_scope :reviewed, :conditions => {:review_status => 'reviewed'}
	named_scope :not_reviewed, :conditions => {:review_status => nil}
	named_scope :en, :conditions => {:lang => 'en'}
end
