class Profile < ActiveRecord::Base
  belongs_to :user
  has_one :doctor_profile, :dependent => :destroy

  accepts_nested_attributes_for :doctor_profile, :allow_destroy => true
  delegate :specialties,
           :certifications,
           :educations,
           :languages,
           :trainings,
           :affiliations,
           :to => :doctor_profile

  validates_presence_of :user_id
  validates_presence_of :name, :title
  validates_associated  :doctor_profile

  attr_protected :user_id
end
