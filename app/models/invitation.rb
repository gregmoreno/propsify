class Invitation < ActiveRecord::Base
  SENDING  = 0
  SENT     = 1
  ACCEPTED = 2


  using_access_control


  belongs_to :created_by,  :class_name => 'User', :foreign_key => :created_by 
  belongs_to :created_for, :class_name => 'User', :foreign_key => :created_for
  belongs_to :voteable,    :polymorphic => true 


  validates_presence_of   :created_by, :created_for, :voteable_id, :voteable_type
  validates_uniqueness_of :token
  validates_presence_of   :token
  validates_uniqueness_of :created_for, :scope => [:voteable_id, :voteable_type], :message => 'has been invited already'

  attr_accessor :email, :name
  validates_presence_of :email, :name, :on => :create 

  before_validation_on_create "self.token = Invitation.generate_token"


  default_scope :order => 'invitations.updated_at DESC'
  named_scope :status_is_sending, :conditions => { :status => Invitation::SENDING }, :order => 'invitations.updated_at ASC'


  %w(SENDING SENT ACCEPTED).each do |status|
    class_eval <<-EOF
      def #{status.downcase}!
        self.status = Invitation::#{status}
        save!
      end

      def #{status.downcase}?
        self.status == Invitation::#{status}
      end
    EOF
  end


  class << self
    def create_for_email(params)
      Invitation.transaction do
        user = User.find_by_email_or_create(:email => params[:email], :name => params[:name])
        Invitation.create(params.merge(:created_for => user)) if user
      end
    end

    def generate_token
      begin
        token = String.random(10)
      end while Invitation.find_by_token(token)
      token
    end

    def find_by_token!(token)
      invitation = find_by_token(token)
      raise ActiveRecord::NotFound if invitation.nil? or invitation.accepted?
      invitation
    end

  end

end
