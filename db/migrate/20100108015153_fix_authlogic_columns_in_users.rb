class FixAuthlogicColumnsInUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change :name, :string, :null => true
      t.change :login, :string, :null => true
      t.change :email, :string, :null => true
      t.change :crypted_password, :string, :null => true
      t.change :password_salt, :string, :null => true
      t.change :persistence_token, :string, :null => true
      t.change :single_access_token, :string, :null => true
      t.change :perishable_token, :string, :null => true
    end
  end

  def self.down
    # some columns have null values so they cannot be reverted to NOT NULL
    #raise ActiveRecord::IrreversibleMigration
  end
end
