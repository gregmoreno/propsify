class RedesignInvite < ActiveRecord::Migration
  def self.up
    create_table :invitations, :force => true do |t|
      t.references :voteable, :polymorphic => true
      t.integer    :created_for
      t.integer    :created_by
      t.string     :token,  :null => false
      t.integer    :status, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
