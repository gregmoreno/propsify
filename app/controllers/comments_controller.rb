class CommentsController < ApplicationController
  #resource_controller
  #belongs_to :user
  
  def index
    @comments = comments 
  end


  # TODO: This is a privilege operation
  def manage
    @comments = comments
  end

  #create.before do
  #  object.user = current_user
  #end
  #create.wants.html do
  #  redirect_to object.user 
  #end

  # TODO: 
  # current_user + not match w/ invitation
  # current_user + match invitation
  
  def invite
    @invitation = Invitation.find_by_code(params[:code]) or raise ActiveRecord::RecordNotFound
  end

  def accept
    @invitation = Invitation.find_by_code(params[:code]) 
    if @invitation
      Review.create_via_invitation(params) 
      # TODO: Should consider user salutation
      flash[:notice] = 'Thank your for your feedback - ' + @invitation.author.name
      redirect_to @invitation.author
    end
    # Silently ignore if something is wrong
  end

  private


  def comments
    if params[:user_id]
      object = @user = User.find(params[:user_id]) 
      @user.comments
    elsif params[:workspace_id]
      object = @workspace = Workspace.find(params[:workspace_id])
      @workspace.comments
    else
      @user = User.current
      @user.accessible_comments
    end

    respond_to do |wants|
      wants.html do
        render "#{object.class.name.tableize}/comments" 
      end
    end
  end


  # TODO: Allow edit w/in 15 minutes after posting

end
