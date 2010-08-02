jQuery(function($) {
  $('#new_user, form.edit_user').validate({
    rules: {
      'user[name]': {
        required:  true,
        maxlength: 100
      },
      'user[email]': {
        required:  true,
        maxlength: 100,
        email:     true
      }
    }
  });

  $('#new_user #user_password').rules('add', {
    required:  true,
    maxlength: 20,
    minlength: 6
  });

  $('#new_user_session').validate({
    rules: {
      'user_session[login]': {
        required: true,
        email:    true
      },
      'user_session[password]': {
        required:  true,
        minlength: 6
      }
    },
  });
});
