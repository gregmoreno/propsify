class WorkspacesController < ApplicationController
  before_filter :require_user, :except => :show

  def index
    # Because we want staff to see all workspaces while others should only
    # see their owned workspaces
    @workspaces = Workspace.with_permissions_to(:list).filter(params).paginate(:page => params[:page])
  end

  def show
    @workspace = Workspace.find(params[:id]) 

    respond_to do |format|
      format.json { render :json => to_json, :callback => params[:callback] }
      format.html { @votes = @workspace.votes.votes_up.recent.paginate(:page => params[:page]) }
    end
  end

  def new
    @workspace = Workspace.new
    authorization_assert!(:create, @workspace)

    find_locations_for_select(@workspace)
  end

  def create
    @workspace = current_user.workspaces.new(params[:workspace])
    authorization_assert!(:create, @workspace)

    if @workspace.save
      notify('Congratulations!.', :success)
      redirect_to workspaces_path
    else
      find_locations_for_select(@workspace)
      render_invalid_create(@workspace)
    end
  end

  def edit
    @workspace = Workspace.find(params[:id])
    authorization_assert!(:update, @workspace)

    find_locations_for_select(@workspace)

    @twitter_account = @workspace.twitter_account
  end

  def update
    @workspace = Workspace.find(params[:id])
    authorization_assert!(:update, @workspace)

    if @workspace.update_attributes(params[:workspace])
      notify "'#{@workspace.name}' has been updated."
      redirect_to(workspaces_path)
    else
      find_locations_for_select(@workspace)
      render_invalid_update(@workspace)
    end
  end

  def destroy
    @workspace = Workspace.find(params[:id])
    authorization_assert!(:destroy, @workspace)

    @workspace.destroy

    notify("Business listing successfully deleted.", :success)
    redirect_to(workspaces_path)
  end

  def widget
    @voteable = Workspace.find(params[:id])
    authorization_assert!(:update, @voteable)
  end


  #######
  private
  #######


  def to_json
    json = {:name => @workspace.name, :url => workspace_url(:id => @workspace.id), :votes_count => @workspace.votes_up}
    votes = @workspace.votes.votes_up.recent.paginate(:page => params[:page]).inject([]) do |l, vote|
      l << { :text => vote.comment.nil? ? '' : vote.comment.text, 
             :created_at => vote.created_at.to_s(:date),
             :url  => user_vote_url(vote.voter, vote),
             :user => { :name => vote.voter.name
                      }
           }
    end
    json.merge(:votes => votes)
  end
end
