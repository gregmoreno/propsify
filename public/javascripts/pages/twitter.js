jQuery(function($) {
new TWTR.Widget({
  search: Twitter.search,
  id: 'twitterfeed',
  loop: true,
  title: 'What\'s being said about...',
  subject: Twitter.subject,
  width: 400,
  height: 300,
  theme: {
    shell: {
      background: '#3082af',
      color: '#ffffff'
    },
    tweets: {
      background: '#ffffff',
      color: '#444444',
      links: '#1985b5'
    }
  }
}).render().start();


});
