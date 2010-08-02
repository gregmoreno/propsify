class Site < ActiveRecord::Base
  cattr_accessor :current

  validates_presence_of :name
  validates_presence_of :domain
end
