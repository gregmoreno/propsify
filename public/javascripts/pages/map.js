jQuery(function($) {

   // var map = new GMap2(document.getElementById("map" ));

  //function initMap() {
    if (GBrowserIsCompatible() && (typeof(locations) != 'undefined') ) {
      var map = new GMap2(document.getElementById("map" ));
  
      //map.setCenter(new GLatLng(37.4419, -122.1419), 13);
      map.addControl(new GLargeMapControl());
  
      // Clicking the marker will hide it
      function createMarker(latlng, item) {
        var marker = new GMarker(latlng);
        var html = "<div class='rating'>" +
                     "<div class='positive'>" +
                       "<span class='number'>" +
                       item.rating +
                       "</span>" +
                     "</div>" +
                   "</div>" +
                   "<div class='details'>" +
                      "<h3>" +
                      "<a href='" + item.url + "'>" +
                      item.name +
                      "</a>" +
                      "</h3>" +
                      "<p>" +
                      item.address +
                      "</p>" +
                    "</div>" 
        GEvent.addListener(marker, "mouseover" , function() {
          map.openInfoWindowHtml(latlng, html);
        });
        return marker;
      }
  
      var bounds = new GLatLngBounds;
      for (var i = 0; i < locations.length; i++) {
        if ((locations[i].lat != null) && (locations[i].lng != null)) {
          var latlng = new GLatLng(locations[i].lat,locations[i].lng)
          bounds.extend(latlng);
          map.addOverlay(createMarker(latlng, locations[i]));
        }
      }
      map.setCenter(bounds.getCenter(),map.getBoundsZoomLevel(bounds));
    }
  //}

});

//window.onload = initMap;
//window.onunload =GUnload;

