module LocationsHelper

  def friendly_select_prompt(locations, default = '-- Select --')
    return default if locations.empty?
    "-- #{locations.map(&:class).uniq.join('/')} --"
  end

  def location_address(location)
    return nil if location.nil?

    [location.street_address, location.city.name, location.country_subdivision.code].join(', ') +  ' ' + location.postal_code
  rescue
    "Invalid address"
  end

  def render_location_brief(location)
    city = location.city.name

    s = [location.street_address, city].join(', ')

    q = {:near => location.id, :city => city.parameterize}
    if params[:q]
      q.merge!(:q => params[:q].parameterize)
    else
      q.merge!(:q => city.parameterize)
    end

    content_tag(:span, link_to(s, search_path(q)), :class => 'location')
  rescue
    "Unknown location"
  end


end
