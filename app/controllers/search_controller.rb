class SearchController < ApplicationController
  #before_filter :set_location

  def index
    if City.current
      @collection = recent_votes
      @collection = recent_workspaces if @collection.empty? 
      render 'index_city'
    else
      render "index_#{Site.current.name.downcase}"
    end
  end

  def city 
    if City.current
      @collection = recent_workspaces 
      render 'index_city'
    else
      raise
    end
  end

  def search
    @collection = search_locatables(params)  
  end

  private

  def recent_votes
    Vote.filter(params.merge(:city_id => City.current.id)).paginate(:page => params[:page])
  end

  def recent_workspaces
    Workspace.filter(params.merge(:city_id => City.current.id)).paginate(:page => params[:page])
  end

  def search_locatables(params)
    return [].paginate if params[:q].blank?

    options = { :page => (params[:page] or 1), :per_page => PER_PAGE }
    order = case params[:sort_by]
      when 'votes_up'
        'votes_up DESC'
      when 'votes_down'
        'votes_down DESC'
      else
        'votes_up DESC'
    end
    options.merge! :order => order 

    if params[:near] 
      @geolocation = near = Location.find(params[:near])
      if near.lat and near.lng
        lat = (near.lat / 180.0) * Math::PI 
        lng = (near.lng / 180.0) * Math::PI

        options.merge! :geo => [lat, lng], :with => {"@geodist" => 0.0..500.0},
          :latitude_attr => :lat, :longitude_attr => :lng 
      end
    end

    if City.current
      options.merge! :conditions => {:city => City.current.name}
    end
    
    if inquiry = (params[:tagged] or params[:q])
      @keywords = inquiry.splitfire
    end

    ThinkingSphinx.search params[:q], options
  end

end
