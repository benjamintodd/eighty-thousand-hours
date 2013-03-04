$(document).ready( function() {
  // submit button for both add and edit education forms
  $("#btn-add-education-submit").click( function() {
    var edit = $("#data").data('edit');
    var profile_id = $("#data").data('profile-id');
    
    if (edit == false)
    {
      var valuesToSubmit = $("#new_education").serialize();
      $.ajax({
        type: 'POST',
        url: '/members/' + profile_id + '/educations',
        data: valuesToSubmit
      });
    }
    else
    {
      var id = $("#id").data('id');
      var valuesToSubmit = $("#edit_education_" + id).serialize();
      $.ajax({
        type: 'PUT',
        url: '/members/' + profile_id + '/educations/' + id,
        data: valuesToSubmit
      });
    }
    return false;
  });

  // cancel button on new education form
  $("#btn-add-education-cancel").click( function() {
    $("#education-form").html("");
    return false;
  });

  // cancel button for edit education form
  $("#btn-edit-education-cancel").click( function() {
    var profile_id = $("#data").data('profile-id');
    var id = $("#id").data('id');
    var valuesToSubmit = "cancel=true";
    $.ajax({
      type: 'PUT',
      url: '/members/' + profile_id + '/educations/' + id,
      data: valuesToSubmit
    });
    return false;
  });

  // if 'current education' checkbox is ticked on new education form
  $("#education_current_education").click( function() {
    // disable end year
    var $year = $("#education_end_date_year");
    $year.attr('disabled', !$year.attr('disabled'));

    // set year to nil options
    $year.attr('value', null);
  });
});