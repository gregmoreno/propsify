class ApplicationController
  # NOTE: There's a corresponding helper for this because we need to override
  # both controller and template accessible routes
  module RoutesHelper
    
    def invitations_path(inviteable)
      send("#{inviteable.class.name.downcase}_invitations_path", inviteable)
    end

    def voteable_path(voteable, options={})
      send("#{voteable.class.name.underscore}_path", voteable, options)
    end

    def workspace_invitations_path(workspace)
      super(:workspace_id => workspace)
    end

  end
end


