module PagesHelper
  def page_info
    title, desc = unless @page_title.blank?
      [@page_title, @page_desc]
    else
      default_page_info
    end

    if params[:page]
      title << " &mdash; page #{params[:page]}"
      desc  << " &mdash; page #{params[:page]}"
    end

    return [title, desc]
  end

  def workspace_page_info(workspace)
    return default_page_info if workspace.new_record?

    location = workspace.city.name.titleize
    votes = pluralize(workspace.votes_up, 'person')

    title = "#{workspace.name}, #{location} &mdash; recommended by #{votes} in #{location}"
    desc  = "#{votes} from #{location} recommends #{workspace.name}. #{workspace.name} is located at #{workspace.address}. "
    desc << "#{workspace.description}." unless workspace.description.blank?

    return [title, desc]
  end

  def city_page_info(city = City.current)
    location = city.name.titleize
    title = "#{location} &mdash; #{location}'s #{default_page_description}"
    desc  = "Looking for a business in #{location}? See the #{default_page_description.downcase} in #{location}."
   
    return [title, desc]
  end

  def user_page_info(user)
    user_name = user.name.titleize
    # TODO: add user city
    votes  = pluralize(@votes_up.total_entries, 'business')
    cities = @votes_up.first(5).collect { |v| v.voteable.location.city.name }.uniq.join(", ")

    title = "#{user_name} recommends #{votes} in #{cities}"
    desc  = title

    return [title, desc]
  end

  def vote_page_info(vote)
    voteable  = vote.voteable
    location  = voteable.city.name.titleize 
    user_name = vote.voter.name
    user_city = location  # TODO: should be the location of voter
    votes = pluralize(voteable.votes_up, 'person')

    title = "#{user_name} from #{user_city} recommends #{voteable.name}, #{location}"
    desc  = "#{votes} recommends #{voteable.name}, #{location}. #{voteable.name} is located at #{voteable.address}."

    return [title, desc]
  end

  def search_page_info
    votes = pluralize(@collection.total_entries, 'recommendation')
    info = "#{votes} #{search_info}"

    return [info, info]
  end

  def search_info
    info = []
    info << "for '#{params[:q]}'" if params[:q]

    location = if @geolocation
                 "#{@geolocation.street_address}, #{@geolocation.city.name.titleize}"
               elsif City.current
                 City.current.name.titleize
               end

    info << "near #{location}" unless location.blank?

    info.join(" ")
  end

  def search_keywords
    if @keywords
      @keywords.uniq.join(', ').downcase      
    else
      default_page_description
    end
  end

  def default_page_info
    [default_page_title, site_tagline]
  end


  def site_name
    "Propsify"
  end

  def site_url
    root_url.gsub(/\/$/, '')
  end

  def site_tagline
    "Collect and spread recommendations for your business"
  end

  def site_title
    "#{site_name} - #{site_tagline}"
  end

  def default_page_title
    "#{site_name} &mdash; #{site_tagline}"
  end

  def default_page_description
    "Most recommended Fitness, Health, Wellness destinations"
  end

  def support_email
    "hello@propsify.com"
  end

  #def page_description(keywords, location)
  #  description = PageMeta.keyword_description(keywords)
  #  description = "Fitness, Health, Wellness destinations" if description.nil?
  #  inquiry = keywords.join(' ') if keywords

  #  { :page_description => "#{location}'s most recommended #{description}",
  #    :meta_description => "Looking for #{inquiry} in #{location}? See the most recommended #{description.downcase} in #{location}."
  #  }
  #end
end
