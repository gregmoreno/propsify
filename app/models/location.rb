class Location < ActiveRecord::Base
  belongs_to :locatable, :polymorphic => true
  belongs_to :country 
  belongs_to :country_subdivision
  belongs_to :city

  validates_presence_of :country_id, :country_subdivision_id, :city_id, :street_address, :postal_code
  validates_length_of   :street_address, :maximum => 255, :allow_blank => true
  validates_length_of   :postal_code,    :maximum => 50,  :allow_blank => true


  before_save :set_geocode_address, :if => :location_changed?
  before_validation "self.country = Country.current"


  def address
    [street_address, city.name, country_subdivision.code].join(', ') +  ' ' + postal_code
  rescue
    "Invalid address"
  end

  protected
  
  def validate 
    validate_location
  end

  def validate_location
    self.country.subdivisions.include?(self.country_subdivision) &&
      self.country_subdivision.cities.include?(self.city)
  end

  def location_changed?
    street_address_changed? || postal_code_changed?
  end

  def set_geocode_address
    # Because geocoding can fail, it shouldn't stopped from saving
    # the location. Also, this would allow change of address later
    geo = GeoKit::Geocoders::MultiGeocoder.geocode(address)
    self.lat, self.lng = geo.lat, geo.lng if geo.success
  end

end
