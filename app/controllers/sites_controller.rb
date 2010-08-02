class SitesController < ApplicationController
  def index
    if Site.current.domain == 'propsify.dev'
      render "#{Site.current.name.downcase}_index"
    else
      redirect_to :controller => 'search', :action => 'index'
    end
  end
end



