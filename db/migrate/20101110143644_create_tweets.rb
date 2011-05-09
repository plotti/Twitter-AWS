class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.string :text
      t.string :username
      t.integer :guid
      t.string :lang
      t.string :time_zone
      t.integer :project_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tweets
  end
end
