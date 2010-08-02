class City < ActiveRecord::Base
  belongs_to :country
  belongs_to :country_subdivision

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :country_id, :case_sensitive => false
  validates_length_of :name, :maximum => 255

  named_scope :sorted, :order => 'name'

  delegate :name, :code, :to => :country, :prefix => true
  delegate :name, :code, :to => :country_subdivision, :prefix => true

  cattr_accessor :current

  def to_s
    "#{name}, #{country_subdivision_code}, #{country_name}"
  end
end
