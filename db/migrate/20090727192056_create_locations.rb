class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :countries, :force => true do |t|
      t.string  :name, :limit => 255
      t.string  :code, :limit => 2
      t.boolean :priority_country, :default => false
    end

    add_index :countries, :priority_country

    create_table :country_subdivisions, :force => true do |t|
      t.references :country
      t.string :name, :limit => 255
      t.string :code, :limit => 2
      t.string :type, :limit => 255
    end

    add_index :country_subdivisions, :country_id
    add_index :country_subdivisions, [ :type, :id ], :unique => true

    create_table :cities, :force => true do |t|
      t.references :country_subdivision
      t.references :country
      t.string :name, :limit => 255
    end

    add_index :cities, :country_subdivision_id
    add_index :cities, :country_id

    create_table :locations, :force => true do |t|
      t.references :locatable,  :polymorphic => true
      t.references :country 
      t.references :country_subdivision 
      t.references :city
      t.string     :street_address, :limit => 255
      t.string     :postal_code, :limit => 50
      t.float      :lat, :lng
    end
  end

  def self.down
    drop_table :countries
    drop_table :country_subdivisions
    drop_table :cities
    drop_table :locations
  end
end
