class ProfilesController < ApplicationController
  before_filter :user

  def new
    @profile = Profile.new(:user => user)
  end

  def create
    @profile = user.profile = Profile.new(params[:profile])
    if @profile.save
      notify 'Your work profile has been updated. Thank you!'
      redirect_to user
    else
      render_invalid_create(@profile)
    end
  end

  def edit
    @profile = user.profile
  end

  def update
    @profile = user.profile
    if @profile.update_attributes(params[:profile])
      notify 'Your profile has been updated.'
      redirect_to user
    else
      render_invalid_update(@profile)
    end
  end

  private

  def user
    # TODO: should be scoped to current_user's accessible users
    @user ||= User.find(params[:user_id])
  end

end
