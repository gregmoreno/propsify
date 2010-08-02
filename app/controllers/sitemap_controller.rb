class SitemapController < ApplicationController
  def show
    @locations = Country.current.cities
  end
end
