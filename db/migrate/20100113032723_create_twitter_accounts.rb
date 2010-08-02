class CreateTwitterAccounts < ActiveRecord::Migration
  def self.up
    create_table :twitter_accounts do |t|
      t.references :owner, :polymorphic => true

      t.string :request_token
      t.string :request_token_secret
      t.text :request_authorization_url

      t.string :access_token
      t.string :access_token_secret

      t.timestamps
    end

    add_index :twitter_accounts, [ :owner_id, :owner_type ], :unique => true
  end

  def self.down
    drop_table :twitter_accounts
  end
end
