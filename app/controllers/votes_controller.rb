class VotesController < ApplicationController
  before_filter :require_user, :except => [:show, :create]

  def create
    create_via_invitation 

    # TODO
    # if valid
    # show thank you page
    # ask if for post to twitter/facebook

    # temp
    redirect_to user_vote_path(@invitation.created_for, @vote)
  end

  def edit  
    @vote = Vote.find(params[:id])
    authorization_assert!(:update, @vote)
  end

  def destroy
    @vote = Vote.find(params[:id])

    authorization_assert!(:delete, @vote)
    voteable = @vote.voteable
    @vote.destroy

    notify('Recommendation permanently deleted', :info)
    redirect_to voteable_path(voteable)
  end


  def show
    @vote = Vote.find(params[:id])
    @votes_up = @vote.voter.voteables.votes_up.recent.except(@vote).paginate(:page => params[:page])
  end


  #######
  private
  #######
  

  def votes
    @voteable ||= voteable
    @voteable.votes.filter(params)
  end

  def create_via_invitation
    @invitation = Invitation.find_by_token!(params[:token])

    raise Authorization::NotAuthorized if voteable != @invitation.voteable

    authenticate_user(@invitation.created_for)
    
    Invitation.transaction do
      @vote = Vote.create params[:vote].merge(:vote => true, :voter => @invitation.created_for, :voteable => voteable)
      @invitation.accepted!
    end

    notify("Thank you for your recommendation.", :success)
  end

end
