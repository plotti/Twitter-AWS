class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :keyword1
      t.string :keyword2
      t.string :keyword3
	  t.string :description 
	  t.string :name 
	  
      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
