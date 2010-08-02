module UsersHelper

  def user_title(user)
    h(user.profile.title) if user.profile
  end


  def user_description(user)
    textilize(user.profile.description) if user.profile
  end

  def user_specialties(user)
    return unless user.profile
    user.profile.specialties.each do |s|
      yield s.name
    end
  end

  def edit_profile_path(user)
    return unless profile = user.profile 
    send("edit_user_#{profile.class.name.underscore}_path", user)
  end

   # If there is a profile, user profile.name
  def user_name(user)
    return nil unless user

    if profile = user.profile
      profile.salutation.blank? ? profile.name : "#{profile.salutation} #{profile.name}"
    else
      h(user.name)
    end
  end

  def render_user(user, options={}) 
    unless current_user
      options = {} unless options
      options = options.merge(:permalink => true)
    end
    content_tag(:span, link_to(user_name(user), user_path(user, options)), :class => 'user')
  end

  def render_user_with_avatar(user, size = :small)
    content_tag(:div, :class => 'avatar') do 
      render_user_avatar(user, size) +
      content_tag(:p, render_user(user))
    end
  end

  def render_user_avatar(user, size=:small)
    gravatar_for user, :alt => user.name, :size => GravatarHelper::SIZES[size.to_sym]
  end

end
