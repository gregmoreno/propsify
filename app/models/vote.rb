class Vote < ActiveRecord::Base
  # These are originally from vote_fu/lib/models/vote.rb
  # I keep getting "Can't dup NilClass" error which is related to unloadble. 
  # It's not easy to extend Vote because the plugin version loads first before
  # my custom changes and if I need some initialization values (e.g. PER_PAGE) it 
  # won't find it because those .rb files that contain them are not yet loaded. 
  # Also it's better to keep everything in one place.

  using_access_control


  # NOTE: Votes belong to the "voteable" interface, and also to voters
  belongs_to :voteable, :polymorphic => true
  belongs_to :voter,    :polymorphic => true
  has_one    :comment,  :dependent => :delete

  accepts_nested_attributes_for :comment, :reject_if => proc { |attrs| attrs['text'].blank? }

  validates_uniqueness_of :voteable_id, :scope => [:voteable_type, :voter_type, :voter_id]

  named_scope :for_voter, lambda { |*args| 
    {:conditions => ["voter_id = ? AND voter_type = ?", args.first.id, args.first.type.name]} 
  }
  named_scope :for_voteable, lambda { |*args| 
    {:conditions => ["voteable_id = ? AND voteable_type = ?", args.first.id, args.first.type.name]} 
  }
  named_scope :recent, lambda { |*args| 
    {:conditions => ["created_at > ?", (args.first || 2.weeks.ago).to_s(:db)]} 
  }
  named_scope :descending, :order => "created_at DESC"

  named_scope :votes_up,   :conditions => 'vote = true'
  named_scope :votes_down, :conditions => 'vote = false'
  named_scope :recent,     :order => 'votes.created_at DESC'
  named_scope :except, lambda { |votes|
    ids = votes.is_a?(Array) ? votes.collect(&:id) : votes.id
    { :conditions => "id NOT IN (#{ids})"
    }
  }

  # Assumes related to workspaces for now
  named_scope :filter_by_city, lambda { |city|
    city_id = is_a?(Numeric) ? city.id : city
    {
      :joins => "LEFT JOIN workspaces ON votes.voteable_id = workspaces.id " +
                "LEFT JOIN locations  ON workspaces.id = locations.locatable_id ",
      :conditions => ["votes.voteable_type = ? AND locations.locatable_type = ? AND locations.city_id = ?", 
                "Workspace", "Workspace", city_id]
    }
  }

  named_scope :with_comments, :joins => :comment

  before_create :build_associated_comment
  after_create  :increment_voteable_counter_cache
  after_create  :notify_voteable_owner_and_voter 
  after_destroy :decrement_voteable_counter_cache

  attr_accessible :created_at
  attr_accessible :vote, :voter, :voteable
  # NOTE why this works and not the attribute writer (as per
  # #accepts_nested_attributes_for documentation) is a head-scratcher
  attr_accessible :comment_attributes

  cattr_accessor :per_page
  @@per_page = PER_PAGE


  class << self
    def filter(params)
      scope = case params[:votes]
        when 'down'
          scope = votes_down
        else
          scope = votes_up
        end

      scope = scope.recent 
      scope = scope.filter_by_city(params[:city_id]) if params[:city_id]
      scope
    end
  end


  #######
  private
  #######

  # to make vote-comment creation atomic
  def build_associated_comment
    if comment
      comment.user = voter
      comment.commentable = voteable
    end
  end

  def increment_voteable_counter_cache
    logger.info "Vote update_voteable_counter_cache: #{voteable_type} #{vote}"

    klass = voteable_type.constantize
    if vote == true
      klass.increment_counter(:votes_up,   voteable_id)
    elsif vote == false
      klass.increment_counter(:votes_down, voteable_id)
    end
  end

  def decrement_voteable_counter_cache
    logger.info "Vote update_voteable_counter_cache: #{voteable_type} #{vote}"

    klass = voteable_type.constantize
    if vote == true
      klass.decrement_counter(:votes_up,   voteable_id)
    elsif vote == false
      klass.decrement_counter(:votes_down, voteable_id)
    end
  end

  def notify_voteable_owner_and_voter
    Notifier.deliver_vote_notice_to_owner(self)
    Notifier.deliver_vote_notice_to_voter(self)
  end

end
