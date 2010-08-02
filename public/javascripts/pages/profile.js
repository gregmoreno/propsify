jQuery(function($) {
  $('#new_profile, form.edit_profile').validate({
    rules: {
      'profile[name]': {
        required: true,
        maxlength: 100
      },
      'profile[title]': {
        required: true,
        maxlength: 100,
      }
    },
  });

});
