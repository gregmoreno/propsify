class InvitationsController < ApplicationController
  before_filter :require_user, :except => [:accept]

  def index
    @invitations = invitations
  end

  def create
    @invitation = invitations.create_for_email(params[:invitation].merge(:created_by => current_user, :voteable => voteable))

    if @invitation && @invitation.valid? 
      notify("Request sent to #{@invitation.created_for.email}", :success)
      redirect_to invitations_path(@invitation.voteable)
    else
      notify("Error creating the request. Please check the name and email.", :error)

      @invitations = invitations 
      render :index
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    authorization_assert!(:destroy, @invitation)

    @voteable = @invitation.voteable
    @invitation.destroy

    notify("Request to #{@invitation.created_for.email} has been deleted", :info)
    redirect_to invitations_path(@voteable)
  end

  def accept
    logout_current_user
    @invitation = Invitation.find_by_token!(params[:token])    
    @voteable   = @invitation.voteable
  rescue
    render :not_found
  end

  def resend
    @invitation = Invitation.find(params[:id])
    authorization_assert!(:update, @invitation)

    if @invitation.sent?
      @invitation.sending!
      notify('The request has been resent', :success)
    end

    @voteable = @invitation.voteable
    redirect_to invitations_path(@voteable)
  end

  #######
  private
  #######


  def invitations
    @voteable ||= voteable
    @voteable.invitations
  end

end
