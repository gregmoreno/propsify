module JavascriptHelper
  def js_collection_locations(collection)
    items = []
    collection.each do |item|
      items << location_params(item) 
    end
    javascript_tag "var locations=#{items.to_json}"
  end

  def location_params(item)
    # TODO: use delegate?
    item = item.voteable if item.respond_to?(:voteable)
    {'name'    => item.name,
     'url'     => workspace_path(item, :permalink => true),
     'address' => render_location_brief(item.location),
     'rating'  => item.votes_up,
     'lat'     => item.lat,
     'lng'     => item.lng
    }
  end

  def js_twitter_params
    params = {
      'search'  => "#{City.current.name} fitness OR health",
      'subject' => City.current.name
    }
    javascript_tag "var Twitter=#{params.to_json}"
  end


  def google_analytics
    code = GA_TRACKERS['propsify_ca']

    javascript_tag do 
      <<-EOF
        var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
        document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
      EOF
    end +
    javascript_tag do
      <<-EOF
        try {
        var pageTracker = _gat._getTracker("#{code}");
        pageTracker._trackPageview();
        } catch(err) {}
      EOF
    end
  end

DEFAULT_WIDGET_TEMPLATE = <<-EOF
div id='props-wrapper'>
  <a href='%s' id='props-action'>
    <img src='%s/system/badges/%s-120x.jpg' alt='%s'/>
  </a>
</div>
<div id='props-modal'>
  <h3 id='props-name'>Loading recommendations...</h3> 
  <div id='props-content'> 
    <div class='listing'></div> 
    <p class='left'><a href='%s'>Read more recommendations...</a></p>
    <p class='right notice'><a href='%s' title='%s'>
      Powered by
      <br>
      <img src='%s/images/site/logo.jpg' alt='%s'/>
    </a></p>
  </div> 
</div>
EOF

DEFAULT_WIDGET_INCLUDE = <<-EOF
<link rel='stylesheet' href='%s/embed/default.css' type='text/css' />
<script type='text/javascript' src='%s/javascripts/lib/jquery.js'></script>
<script type='text/javascript' src='%s/javascripts/lib/jquery.simplemodal.js'></script>
EOF

# Currently not used until I figured out how to deal with escape chars
DEFAULT_WIDGET_JS = <<-EOF
<script type='text/javascript'>
  document.write(unescape('\%3Cscript src=\"http://propsify.ca/embed/props.widget.js\" type=\"text/javascript\"\%3E\%3C/script\%3E'));
</script>
EOF

DEFAULT_WIDGET_PARAMS = <<-EOF
<script type='text/javascript'>
  $(function() {
    $('a#props-action').propsModalWidget({
      limit:   10,
      id:      '%s',
      account: '%s',
    }); 
  });
</script> 
EOF

  def default_widget_code(voteable)
    type = 'b' # assume it is workspace for now
    id   = voteable.id 
    url  = voteable_url(voteable)

    DEFAULT_WIDGET_TEMPLATE % [url, site_url, id, site_title, url, site_url, site_title, site_url, site_title] +
    DEFAULT_WIDGET_INCLUDE % ([site_url]*3) +
    # Because I'm having problem dealing with escape chars
    "<script type='text/javascript'>document.write(unescape('\%3Cscript src=\"#{site_url}/embed/props.widget.js\" type=\"text/javascript\"\%3E\%3C/script\%3E'));</script>" +
    DEFAULT_WIDGET_PARAMS % [voteable.id, type]  
  end

end
