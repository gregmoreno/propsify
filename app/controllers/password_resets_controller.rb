class PasswordResetsController < ApplicationController

  before_filter :find_user_from_perishable_token, :only => [ :edit, :update ]

  def new
    render
  end

  def create
    if @user = User.find_by_email(params[:email])
      @user.deliver_password_reset_instructions!
      notify 'Instructions to reset your password have been emailed to you.', :success
      redirect_to new_user_session_path

    else
      flash.now[:error] = 'No user was found with that email address.'
      render :action => 'new'
    end
  end

  def edit
    render
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

    if @user.save
      notify 'Password successfully updated', :success
      redirect_to home_path

    else
      flash.now[:error] = 'There was an error in changing your password. Please check your entries below.'
      render :action => 'edit'
    end
  end

  private

    def find_user_from_perishable_token
      unless @user = User.find_using_perishable_token(params[:id])
        notify "We're sorry, but we could not locate your account. " +
          "If you are having issues try copying and pasting the URL from your email into your browser or restarting the reset password process."

        redirect_to new_user_session_path
      end
    end

end
