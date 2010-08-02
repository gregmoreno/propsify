module CommentsHelper

  def comment_tag(vote, &block)
    # TODO: Mark the comment if it's a review, or just a comment
    # Or if comment.owner recommends user
    # e.g. if comment.user.voted_for?(user)
    
    html = content_tag(:div, :class => 'comment') do
      content_tag(:div, capture(&block), :class => 'content')
    end
    concat(html)
  end


  def render_comment_text(comment, html_options={})
    return if comment.text.blank?
    simple_format(comment.text, html_options)
  end

  def render_comment_user(comment)
    if comment.anonymous
      "Anonymous" 
    else
      render_user(comment.user)
    end
  end

end
