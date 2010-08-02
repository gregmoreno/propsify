class CreateWorkspaces < ActiveRecord::Migration
  def self.up
    create_table :workspaces do |t|
      t.references  :owner
      t.string      :name, :limit => 255
      t.string      :contact_numbers, :limit => 255
      t.text        :description, :urls, :videos, :photos
      t.integer     :votes_up,     :default => 0
      t.integer     :votes_down,   :default => 0
      t.integer     :votes_rating, :default => 0
      t.column      :delta, :boolean, :default => false
      t.timestamps
    end

    [:name, :description, :delta].each do |f|
      add_index :workspaces, f
    end
  end

  def self.down
    drop_table :workspaces
  end
end
