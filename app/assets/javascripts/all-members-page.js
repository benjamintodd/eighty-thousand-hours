$(document).ready( function() {
  // display popup box when mouse hovers over member
  var popup_hover = false;
  var config = {
    over: showPopup,
    timeout: 50,   // time until out function is called after cursor moves away
    interval: 200,  // time until over function is called after cursor hovers
    out: hidePopup
  };
  $(".profile-link").hoverIntent(config);

  // don't hide popup if mouse is hovering over it
  $("#profile-popup").hover( function() {
    popup_hover = true
  }, function() {
    popup_hover = false;
    setTimeout( function() {
      $("#profile-popup").hide();
    }, 300);
  });
});

function showPopup()
{
  // display popup
  var id = parseInt($(this).closest(".eighty-thousand-hours-profile-condensed").attr('id'));
  var left_pos = $(this).offset().left;
  var top_pos = $(this).offset().top;
  var params = "id=" + id + "&left_pos=" + left_pos + "&top_pos=" + top_pos + "&page=all_members";
  
  $.ajax({
    type: 'GET',
    url: '/members/display_profile_hover_info',
    data: params
  });
}
function hidePopup()
{
  // check whether mouse has moved to hover over popup
  if (popup_hover == false)
  {
    $("#profile-hover").hide();
  }
}