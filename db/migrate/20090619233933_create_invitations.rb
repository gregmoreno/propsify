class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      # owner - invitation is from
      # user  - invitation recipient
      # author - who actually created the invitation 
      # e.g. staff created the invitation in behalf of Mr. Gates
      t.references :owner, :user, :author
      t.string :code, :type, :email, :limit => 100
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
