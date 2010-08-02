class TwitterAccountsController < ApplicationController

  before_filter :require_user
  # namespaced under settings (UsersController) and workspaces, thus
  # the funny before_filter's and polymorphic paths
  # REFACTOR may be needed
  before_filter :load_user
  before_filter :load_workspace
  filter_access_to :all, :attribute_check => true, :load_method => :load_twitter_account

  def edit
    @twitter_account.request_authorization! :callback => authorize_url
    redirect_to @twitter_account.request_authorization_url
  end

  def authorize
    if @twitter_account.authorize! :verifier => params[:oauth_verifier]
      notify 'Twitter updates enabled', :success
    end

    redirect_to edit_parent_path
  end

  def destroy
    @twitter_account.deauthorize!
    notify 'Twitter updates disabled'
    redirect_to edit_parent_path
  end

  protected

    def load_user
      @user = params[:user_id] ? User.find(params[:user_id]) : current_user
    end

    def load_workspace
      @workspace = @user.workspaces.find(params[:workspace_id]) if params[:workspace_id]
    end

    # use the workspace's Twitter account if a workspace is set,
    # otherwise assume user's Twitter account
    def load_twitter_account
      # FIXME would this be better placed in the models?
      @twitter_account = @workspace ? @workspace.twitter_account || @workspace.create_twitter_account :
        @user.twitter_account || @user.create_twitter_account
    end

  private

    # More of these path helpers in TwitterAccountsHelper...

    def authorize_url
      polymorphic_url([ @workspace, :twitter_account ], :action => 'authorize')
    end

    def edit_parent_path
      edit_polymorphic_path(@workspace || :settings)
    end

end
