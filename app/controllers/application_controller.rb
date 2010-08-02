# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include ApplicationController::AccessControl
  include ApplicationController::RoutesHelper

  helper :all # include all helpers, all the time

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  filter_parameter_logging :password # Scrub sensitive parameters from your log

  private

  def render_invalid_create(record)
    respond_to do |wants|
      wants.html do
        render :action => :new
      end
    end
  end

  def render_invalid_update(record)
    notify("Sorry, we cannot save your changes. Please see the errors below and try again", :error)

    respond_to do |wants|
      wants.html do
        render :action => :edit
      end
    end
  end


  def notify(s, type = :info)
    flash[type] = s
  end
  
  VOTEABLE_CLASSES = Workspace, User

  def voteable
    VOTEABLE_CLASSES.each do |klass|
      if id = params["#{klass.name.underscore}_id"]
        return klass.find(id)
      end
    end
  end


  #def load_invitation_using_token!
  #  invitation = Invitation.find_by_token(params[:token])
  #  raise ActiveRecord::NotFound if invitation.nil? or invitation.accepted?
  #  invitation
  #end

  def find_locations_for_select(object)
    if object and object.location
      @country_subdivisions = CountrySubdivision.sorted.find_all_by_country_id(object.location.country)
      @cities               = City.sorted.find_all_by_country_subdivision_id(object.location.country_subdivision)
    else
      @country_subdivisions = CountrySubdivision.sorted.find_all_by_country_id(Country.current)
      @cities = []
    end
  end
  
end
