class UsersController < ApplicationController

  before_filter :require_user, :except => [:show, :new, :create]
  filter_resource_access :additional_member => [ :start ]

  def index
    @users = User.with_permissions_to(:read).filter(params).paginate(:page => params[:page])
  end

  def show
    @votes_up = @user.voteables.votes_up.recent.paginate(:page => params[:page]) 
  end

  def new
    # TODO: redirect to account if already logged-in or show a message
    if logged_in?
      # TODO choose one or improve
      notify 'You are already logged in.'
      redirect_to user_path(current_user, :permalink => true)
    end
  end
  
  def create
    if @user.save
      notify('Congratulations! Your account is ready.', :success)
      redirect_back_or_default(start_url)
    else
      notify('There was a problem creating your account.', :error)
      render_invalid_create(@user)
    end
  end

  def edit
    @twitter_account = @user.twitter_account
  end
  
  def update
    if @user.update_attributes(params[:user])
      notify 'User profile updated', :success
      redirect_back_or_default(@user == current_user ? edit_settings_path : edit_user_path(@user))
    else
      render_invalid_update(@user)  
    end
  end

  def start
    render
  end

  protected

    def load_user
      @user = params[:id] ? User.find(params[:id]) : current_user
    end

end
