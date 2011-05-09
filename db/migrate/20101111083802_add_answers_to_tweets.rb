class AddAnswersToTweets < ActiveRecord::Migration
  def self.up
  	add_column :tweets, :sentiment, :string
  	add_column :tweets, :answer1, :text
  	add_column :tweets, :answer2, :text
  	add_column :tweets, :answer3, :text
  	add_column :tweets, :review_status, :string
  	add_column :tweets, :hit_id, :string
  	add_column :tweets, :hit_url, :string
  end

  def self.down
  	remove_column :tweets, :sentiment
  	remove_column :tweets, :answer1
  	remove_column :tweets, :answer2
  	remove_column :tweets, :answer3
  	remove_column :tweets, :review_status
  	remove_column :tweets, :string
  	remove_column :tweets, :hit_url
  end
end
