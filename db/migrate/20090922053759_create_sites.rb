class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string  :domain  # propsify.com 
      t.string  :name
    end
  end

  def self.down
    drop_table :sites
  end
end
