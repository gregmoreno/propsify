class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.column :login,                     :string, :limit => 40
      t.column :name,                      :string, :limit => 100, :default => '', :null => true
      t.column :email,                     :string, :limit => 100
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :remember_token,            :string, :limit => 40
      t.column :remember_token_expires_at, :datetime
      t.timestamps
    end
    add_index :users, :login, :unique => true

    create_table :profiles, :force => true do |t|
      t.references :user
      t.string     :salutation, :name, :title, :default => ''
      t.text       :description, :default => ''
      t.timestamps
    end
  end

  def self.down
    drop_table :users
    drop_table :profiles
  end
end
