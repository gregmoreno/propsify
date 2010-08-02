class UserSessionsController < ApplicationController
  before_filter :require_user, :only => [:destroy]

  def new
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new(params[:user_session])

    if @user_session.save
      notify("Welcome back #{@user_session.user.name}", :success)

      path = @user_session.user.workspaces.count ? workspaces_path : account_url
      redirect_back_or_default(path)
    else
      if @user_session.errors[:base].any?
        notify("You did not provide any login information", :error)
      else
        notify("There was a problem logging you in. Please try again.", :error)
      end

      render_invalid_create(@user_session)
    end
  end
  
  def destroy
    current_user_session.destroy
    redirect_back_or_default(root_url)
  end
end
