jQuery(function($) {
  $('#new_workspace, form.edit_workspace').validate({
    rules: {
      'workspace[name]': {
        required: true,
        maxlength: 255
      },
      'workspace[location_attributes][street_address]': {
        required: true,
        maxlength: 255
      },
      'workspace[location_attributes][postal_code]': {
        required: true,
        maxlength: 10
      },
      'workspace[location_attributes][country_subdivision_id]': 'required',
      'workspace[location_attributes][city_id]': 'required',
    },
  });


  $('#login').validate({
    rules: {
      'login': 'required',
      'password': 'required'
    },
    messages: {
      'login': 'Please enter your email',
      'password': 'Please enter a password'
    }
  });
});
