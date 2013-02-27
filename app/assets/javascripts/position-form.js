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
});