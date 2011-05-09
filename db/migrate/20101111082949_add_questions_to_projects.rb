class AddQuestionsToProjects < ActiveRecord::Migration
  def self.up
  	add_column :projects, :question1, :text
  	add_column :projects, :question2, :text
  	add_column :projects, :question3, :text
  	add_column :projects, :quality_requirement, :integer, :null => false, :default => 85
  end

  def self.down
  	remove_column :projects, :question1
  	remove_column :projects, :question2
  	remove_column :projects, :question3
  	remove_column :projects, :quality_requirement
  end
end
