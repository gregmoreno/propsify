# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def special_page?
    ['/', '/login', '/signup', '/register'].include?(request.path)
  end

  def flash_notice
    html = if flash[:success]
      content_tag(:div, flash[:success], :class => :success)
    elsif flash[:error]
      content_tag(:div, flash[:error], :class => :error)
    elsif flash[:info]
      content_tag(:div, flash[:info], :class => :info)
    elsif flash[:warning]
      content_tag(:div, flash[:warning], :class => :warning)
    end

    flash.discard
    html
  end


  def render_date(date, options = :date)
    content_tag(:span, date.to_s(options), :class => 'date') if date
  end

  def render_email(email)
    h email 
  end

  def render_city(city)
    link_to(city.name.titleize, city_path(:city => city.name.parameterize), :title => "#{city} recommendations")
  end

  def render_delete_link(object)
    return unless permitted_to?(:delete, object)

    path = send("#{object.class.name.downcase}_path", object)
    if object.is_a?(Workspace)
      confirm = 'This will permanently delete the business and recommendations. Are your sure?'
    else
      confirm = 'This will delete the item permanently. Are you sure?'
    end

    link_to('Delete', path, :method => :delete, :confirm => confirm)
  end

  def pluralize_verb(count, singular)
    if count.to_i < 2
      "#{singular.pluralize}"
    else
      "#{singular}"
    end
  end

end

