class User < ActiveRecord::Base
  acts_as_authentic do |config|
    config.validate_login_field = false
    config.disable_perishable_token_maintenance = true
    config.perishable_token_valid_for = 30.minutes
  end
   
  acts_as_voter
  acts_as_voteable
  acts_as_commentable

  validates_presence_of     :name
  validates_length_of       :name,     :maximum => 100

  has_one  :profile
  has_many :invitations, :dependent => :destroy, :foreign_key => :created_by
  has_many :voteables,   :class_name => 'Vote', :as => :voter
  has_one :twitter_account, :as => :owner, :dependent => :destroy
  accepts_nested_attributes_for :invitations, :allow_destroy => true

  # owned clinics, office, etc.
  has_many :workspaces, :foreign_key => :owner_id, :dependent => :nullify 

  delegate :tweet, :to => :twitter_account, :allow_nil => true

  default_scope :order => 'lower(users.name) ASC'


  before_save  :login_email_sanity
  after_create :welcome_user 


  cattr_accessor :current
  cattr_accessor :per_page
  @@per_page = PER_PAGE * 3

  def password_before_type_cast
    ""
  end
  alias_method :password_confirmation_before_type_cast, :password_before_type_cast


  def name
    self['name'].blank? ? 'anonymous' : self['name']
  end

  def first_name
    self.name.scan(/\w+/).first
  end
  
  def role
    role = read_attribute(:role)
    (role.blank? ? :member : role).to_sym
  end

  def role!(name)
    self.role = name.to_s 
    save!
  end

  def role_symbols
    [role]
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions self
  end

  class << self
    def filter(params)
      self
    end

    # TODO: set protection from mass-assignment

    def find_by_email_or_create(params)
      user = User.find_by_email(params[:email].downcase) # or User.find(params[:id])
      return user unless user.nil?

      password = params[:password] || String.random(6)
      create(params.merge(:password => password, :password_confirmation => password))
    end

    def root
      @root ||= User.find_by_name("propsroot") 
    end
  end


  protected
    
  def login_email_sanity 
    self.login = email
  end

  def welcome_user
    Notifier.deliver_welcome(self)
  end

end
