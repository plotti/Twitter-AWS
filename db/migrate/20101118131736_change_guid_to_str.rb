class ChangeGuidToStr < ActiveRecord::Migration
  def self.up
	  change_column :tweets, :guid, :string
  end

  def self.down
  end
end
