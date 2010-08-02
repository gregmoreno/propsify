class Workspace < ActiveRecord::Base
  using_access_control

  acts_as_voteable
  acts_as_commentable

  belongs_to :owner,       :class_name => 'User' 
  has_one    :location,    :as => :locatable, :dependent => :destroy
  has_many   :invitations, :as => :voteable,  :dependent => :destroy
  has_one :twitter_account, :as => :owner, :dependent => :destroy

  is_taggable :tags

  accepts_nested_attributes_for :location, :allow_destroy => true
  delegate :country, :country_subdivision, :city, :address, :street_address, :lat, :lng, :to => :location
  delegate :tweet, :to => :twitter_account, :allow_nil => true

  validates_presence_of :name, :owner_id
  validates_length_of   :name, :maximum => 255
  validates_associated  :location 


  after_create :update_creator_role


  named_scope :recently_created,  :order => 'workspaces.created_at DESC'
  named_scope :recently_updated,  :order => 'workspaces.updated_at DESC'
  named_scope :most_recommended,  :order => 'workspaces.votes_up DESC'
  named_scope :least_recommended, :order => 'workspaces.votes_down ASC'
  named_scope :by_name,           :order => 'lower(workspaces.name) ASC'

  named_scope :filter_by_city, lambda { |city|
    city_id = city.is_a?(Numeric) ? city : city.id
    { :joins => :location,
      :conditions => {'locations.city_id' => city_id}
    }
  }

  named_scope :filter_by_postal_code, lambda { |postal_code|
    { :joins => :location,
      :conditions => {'locations.postal_code' => postal_code}
    }
  }

  named_scope :tagged, lambda { |tags|
    unless tags.is_a?(Array)
      tags = '' if tags.nil?
      tags = tags.splitfire
    end
    { :include => :tags,
      :conditions => ["workspaces.id IN(SELECT workspaces.id FROM workspaces 
                       LEFT JOIN taggings ON workspaces.id = taggings.taggable_id 
                       LEFT JOIN tags on taggings.tag_id = tags.id
                       WHERE tags.name IN (?) AND taggings.taggable_type = ? 
                       GROUP BY workspaces.id HAVING count(tags.id) = ?)", tags, 'Workspace', tags.size]
    }
  }

  define_index do
    indexes name
    indexes description

    indexes [
      location.street_address, 
      location.city.name,
      location.country_subdivision.name, 
      location.country_subdivision.code
      ], :as => :location
    indexes location.city.name, :as => :city

    has location(:id), :as => :location_id
    has 'RADIANS(locations.lat)', :as => :lat, :type => :float
    has 'RADIANS(locations.lng)', :as => :lng, :type => :float
    set_property :latitude_attr  => 'lat'
    set_property :longitude_attr => 'lng'

    # Don't search for now
    #indexes tags.name, :as => :tags

    has votes_up, votes_down, votes_rating

    group_by 'locations.lat', 'locations.lng'

    set_property :delta => true
  end 


  cattr_accessor :per_page
  @@per_page = PER_PAGE

  class << self
    def filter(params)
      scope = if params[:sorted] && self.respond_to?(params[:sorted])
                self.send(params[:sorted]) 
              else
                most_recommended
              end
 
      scope = scope.tagged(params[:tagged]) if params[:tagged]
      scope = scope.filter_by_city(params[:city_id]) if params[:city_id]
      scope
    end
  end


  #######
  private
  #######
  

  def update_creator_role
    unless self.owner.role == :owner
      self.owner.role!(:owner)
    end
  end

end
