module WorkspacesHelper
  def workspace_name(workspace)
    return if workspace.nil?
    h workspace.name
  end

  def workspace_location(workspace)
    return if workspace.nil?
    location_address(workspace.location)
  end


  def render_workspace_name(workspace, options={})
    unless current_user
      options = {} unless options
      options = options.merge(:permalink => true)
    end
    link_to workspace_name(workspace), workspace_path(workspace, options)
  end

  def render_workspace_description(workspace, option=false)
    return if workspace.nil? or workspace.description.blank?
    desc = case option 
      when :brief 
        truncate(workspace.description, :length => 140, :ommission => link_to('...', workspace))
      else
        simple_format(workspace.description)
      end

    content_tag(:div, desc, :class => 'description')
  end

  def render_workspace_location(workspace, option=false)
    return if workspace.nil?
    case option
      when :brief
        render_location_brief(workspace.location)
      else
        render_location_address(workspace.location)
    end
  end

  def render_workspace_meta(workspace)
    text = "created"
    text << " by #{render_user(workspace.owner)}" unless current_user == workspace.owner
    text << " last "
    text << " #{render_date(workspace.created_at)}"
  end

  def render_workspace_contact_numbers(workspace, option=false)
    return if workspace.nil? or workspace.contact_numbers.blank?
    case option
      when :list
        content_tag(:div, simple_format(workspace.contact_numbers), :class => 'contact_numbers')
      else
        content_tag(:span, workspace.contact_numbers, :class => 'contact_numbers')
    end
  end

  def setup_workspace(workspace)
    returning(workspace) do |w|
      w.location = Location.new if w.location.nil?
    end
  end


end
