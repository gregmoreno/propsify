(function($) {
  $.fn.propsModalWidget = function(options) {
    var cache    = null;
    var settings = $.extend(true, {}, $.fn.propsModalWidget.defaults, options);

    function onComplete(data) {
      cache = data;

      var list  = $('#props-content .listing').empty(),
          count = 0,
          valid;

      $('#props-name').html('Recommendations for ' + data.name);

      $.each(eval(data.votes), function(index, vote) {
        list.append(
            '<div class="comment">' +
               '<div class="content">' +
                 '<div class="quote">' +
                    vote.text +
                 '</div>' +
               '</div>' +  // content
               '<div class="info">' +
                 '<a href="' + vote.url  + ' ">' +
                   'Recommended by ' +
                   '<span class="user">' +
                     vote.user.name +
                   '</span> last ' +
                   '<span class="date">' +
                     vote.created_at +
                   '</span>' +
                 '</a>' +
               '</div>' + // info
            '</div>');

        if (++count == settings.limit) {
          return false;
        }
      });
    }

    return this.each(function() {
      if (cache) {
        onComplete(cache)
      } else {
        var api = 'http://propsify.ca/api/';
        var url = api + settings.account + '/' + settings.id + '.json?callback=?'
        $.getJSON(url, onComplete);
      }

      $(this).click(function() {
        $('#props-modal').modal();
        return false;
      });
    });

  };


  $.fn.propsModalWidget.defaults = {
    limit   : 5
   };

})(jQuery);
