module VotesHelper
  # ex:
  # def render_voteable_name(voteable)
  #   send("render_#{voteable.class.name.downcase}_name", voteable)
  # end
  # => render_workspace_name(workspace)
  # If you're looking for all info, use workspaces/_info
  ['name', 'description', 'location', 'contact_numbers'].each do |f|
    class_eval <<-EOF
      def render_voteable_#{f}(voteable, options=nil)
        send(\"render_\#\{voteable.class.name.downcase\}_#{f}\", voteable, options)
      end
    EOF
  end

  def voteable_name(voteable)
    klass = voteable.class.name.downcase
    send("#{klass}_name", voteable)
  end

  def render_voteable_votes_note(voteable)
    votes = voteable.votes_up.to_i
    if votes > 0
      "#{pluralize(voteable.votes_up, 'person')} 
       #{pluralize_verb(voteable.votes_up, "recommend")}
       #{render_voteable_name(voteable)}."
    else
      "There are no recommendations for
       #{render_voteable_name(voteable)}."
    end
  end

  def render_votes_text(vote)
    return unless vote.comment
    render :partial => 'votes/text', :locals => {:vote => vote}
  end

  def render_user_vote_note(user, vote)
    'Recommended by ' + render_user(user) + ' last ' + render_date(vote.created_at)
  end

  def render_vote_note(vote)
    "Recommended by #{vote.voter.name} last #{render_date(vote.created_at)}"
  end

  def render_voteable_up_count(voteable)
    pluralize(voteable.votes_up, 'recommendation')
  end

end
