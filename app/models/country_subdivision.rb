class CountrySubdivision < ActiveRecord::Base

  belongs_to :country
  has_many :cities

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :country_id, :case_sensitive => false
  validates_length_of :name, :maximum => 255
  validates_length_of :code, :maximum => 2, :allow_blank => true

  named_scope :sorted, :order => 'name'

  delegate :name, :code, :to => :country, :prefix => true

  def to_s
    "#{name}, #{country_name}"
  end

  # XXX: Hack due to polymorphic design of locations:
  # Just to ensure that all location-type models have country_subdivisions
  def country_subdivision; self; end

end
