module TagsHelper
  def render_tag(tag, options={})
    return if tag.nil?
    # TODO: search is faster it seems. use search_path if so
    url = search_path({:q => tag.name}.merge(options))
    content_tag(:span,  link_to(tag.name, url, :class => 'tag'))
  end
end
