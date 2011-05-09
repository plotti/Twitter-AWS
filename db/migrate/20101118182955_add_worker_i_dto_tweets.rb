class AddWorkerIDtoTweets < ActiveRecord::Migration
  def self.up
  	add_column :tweets, :worker_id, :string
  end

  def self.down
  	remove_column :tweets, :worker_id
  end
  
end
