$(document).ready( function() {
  $("#btn-add-position-submit").click( function() {
    var edit = $("#data").data('edit');
    var profile_id = $("#data").data('profile-id');
    
    if (edit == false)
    {
      var valuesToSubmit = $("#new_position").serialize();
      $.ajax({
        type: 'POST',
        url: '/members/' + profile_id + '/positions',
        data: valuesToSubmit
      });
    }
    else
    {
      var id = $("#id").data('id');
      var valuesToSubmit = $("#edit_position_" + id).serialize();
      $.ajax({
        type: 'PUT',
        url: '/members/' + profile_id + '/positions/' + id,
        data: valuesToSubmit
      });
    }
    return false;
  });

  $(".btn.cancel").click( function() {
    $("#position-form").html("");
    return false;
  });

  $("#btn-edit-position-cancel").click( function() {
    var profile_id = $("#data").data('profile-id');
    var id = $("#id").data('id');
    var valuesToSubmit = "cancel=true";
    $.ajax({
      type: 'PUT',
      url: '/members/' + profile_id + '/positions/' + id,
      data: valuesToSubmit
    });
    return false;
  });

  $("#position_current_position").click( function() {
    // disable end date month and year
    var $month = $("#position_end_date_month");
    $month.attr('disabled', !$month.attr('disabled'));
    var $year = $("#position_end_date_year");
    $year.attr('disabled', !$year.attr('disabled'));

    // set month and year to nil options
    $month.children("option").filter( function() {
      return $(this).text() == "Month";
    }).attr('selected', true);
    $year.attr('value', null);
  });
});