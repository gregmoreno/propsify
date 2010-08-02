class Country < ActiveRecord::Base
  has_many :subdivisions, :class_name => 'CountrySubdivision'
  has_many :cities

  validates_presence_of   :name, :code
  validates_uniqueness_of :name, :code
  validates_length_of     :name, :maximum => 255
  validates_length_of     :code, :maximum => 2

  named_scope :sorted, :order => 'priority_country DESC, name ASC'

  cattr_accessor :current

  def to_s
    name
  end

  # XXX: Hacks due to polymorphic design of locations:
  # Just to ensure that all location-type models have countries...
  def country; self; end
  # ... and country_subdivisions
  def country_subdivision; nil; end

end
