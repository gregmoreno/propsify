class DropSlugs < ActiveRecord::Migration
  def self.up
    drop_table :slugs
  end

  def self.down
    # You really can rollback this one
  end
end
