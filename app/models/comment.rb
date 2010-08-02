class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true
  belongs_to :user
  belongs_to :vote

  named_scope :recent, :order => 'comments.created_at DESC'
end
