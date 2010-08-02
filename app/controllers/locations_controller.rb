# TODO: Needs improvement
class LocationsController < ApplicationController
  layout nil

  def index
    if params[:country_id]
      country = Country.find params[:country_id]
      country_subdivisions = country.subdivisions.sorted
      cities = country.cities.sorted

      render :update do |page|
        if !country_subdivisions.empty?
          page['country-subdivision-select'].replace_html :partial => 'options',
            :locals => { :locations => country_subdivisions }
          page['city-select'].replace_html :partial => 'options',
              :locals => { :locations => [] }

        else
          page['country-subdivisions-field'].hide

          if !cities.empty?
            page['city-select'].replace_html :partial => 'options',
              :locals => { :locations => cities }
          end
        end
      end

    elsif params[:country_subdivision_id]
      country_subdivision = CountrySubdivision.find params[:country_subdivision_id]
      cities = country_subdivision.cities.sorted

      render :update do |page|
        page['city-select'].replace_html :partial => 'options',
          :locals => { :locations => cities }
      end
    end
  end

end
