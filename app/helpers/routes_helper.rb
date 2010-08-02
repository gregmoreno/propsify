module RoutesHelper
  def invitations_path(voteable)
    send("#{voteable.class.name.underscore}_invitations_path", voteable)
  end

  def votes_path(voteable)
    send("#{voteable.class.name.underscore}_votes_path", voteable)
  end

  def voteable_path(voteable)
    send("#{voteable.class.name.underscore}_path", voteable)
  end

  def voteables_path(voteable)
    send("#{voteable.class.name.underscore}s_path")
  end 

  def voteable_url(voteable)
    send("#{voteable.class.name.underscore}_url", voteable)
  end

  def workspace_invitations_path(workspace)
    super(:workspace_id => workspace)
  end

  def workspace_votes_path(workspace)
    super(:workspace_id => workspace)
  end

  def home_path
    current_user.workspaces.count ? workspaces_path : account_url
  end
end
