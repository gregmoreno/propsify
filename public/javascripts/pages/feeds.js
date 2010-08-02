jQuery(function($) {
//
// example code to read entries from a user's friendfeed.com public feed
// and insert into the current document, using jQuery AJAX facilities.
//
// see:
//    friendfeed API: http://code.google.com/p/friendfeed-api/wiki/ApiDocumentation
//    jquery        : http://jquery.com/
//
// john girvin, july 2009
// public domain
//
 
// convert rfc3339 formatted date (as returned by friendfeed api) to
// a normal javascript date object
//
// adapted from: http://www.ibm.com/developerworks/library/x-atom2json.html
function rfc3339ToDate(val) {
    var pattern = /^(\d{4})(?:-(\d{2}))?(?:-(\d{2}))?(?:[Tt](\d{2}):(\d{2}):(\d{2})(?:\.(\d*))?)?([Zz])?(?:([+-])(\d{2}):(\d{2}))?$/;
 
    var m = pattern.exec(val);
    var year = new Number(m[1] ? m[1] : 0);
    var month = new Number(m[2] ? m[2] : 0);
    var day = new Number(m[3] ? m[3] : 0);
    var hour = new Number(m[4] ? m[4] : 0);
    var minute = new Number(m[5] ? m[5] : 0);
    var second = new Number(m[6] ? m[6] : 0);
    var millis = new Number(m[7] ? m[7] : 0);
    var gmt = m[8];
    var dir = m[9];
    var offhour = new Number(m[10] ? m[10] : 0);
    var offmin = new Number(m[11] ? m[11] : 0);
 
    if (dir && offhour && offmin) {
        var offset = ((offhour * 60) + offmin);
        if (dir == "+") {
            minute -= offset;
        } else if (dir == "-") {
            minute += offset;
        }
    }
 
    return new Date(Date.UTC(year, month, day, hour, minute, second, millis));
}
 
// zeropad a number to two digits
function pad(v) {
    if (v < 10) {
        v = "0" + v;
    }
    return v;
}
 
// format a date returned from friendfeed api for display
function formatFriendFeedDate(ffdate) {
    var m = new Array('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec');
    var d = rfc3339ToDate(ffdate);
    return d.getDate() + ' ' + m[d.getMonth()-1] + ', ' + pad(d.getHours()) + ':' + pad(d.getMinutes());
}
 
// populate friendfeed container via ajax
jQuery(document).ready(function() {
    // friendfeed: name of user who's feed we want to retrieve
    var usr = 'johngirvin';
    var nam = 'John Girvin';
    // friendfeed: number of entries to retrieve
    var num = 5;
 
    // call friendfeed api
    jQuery.getJSON(
        // construct the fetch url
        'http://friendfeed.com/api/feed/user/' + usr + '?num=' + num + '&amp;callback=?',
 
        // build content from api results
        function(data) {
            // reference container to hold generated content
            var container = jQuery('#feedContent');
 
            // loop for each friendfeed entry retrieved
            jQuery.each(data.entries, function(i, entry) {
                // ignore entry if it is marked as 'hidden'
                if (entry.hidden != true) {
                    // reference the service details
                    var svc = entry.service;
 
                    // build markup for entry - adapt as you require
                    var t = '';
 
                    t += '<li>';
 
                    t += '<div class="friendfeed_text">';
                    t += '<a href="'+entry.link+'" target="_blank">';
                    t += entry.title;
                    t += '</a>';
 
                    t += '<div class="friendfeed_date">';
                    t += formatFriendFeedDate(entry.published);
                    t += ' via '
 
                    t += '<a title="View '+nam+'\'s profile on '+svc.name+'" href="'+svc.profileUrl+'" target="_blank">';
                    t += svc.name;
                    t += '</a>';
 
                    t += '</div>';
                    t += '</div>';
 
                    t += '</li>';
 
                    // append content to container
                    container.append(t);
                }
            });
        }
    );
});

});
