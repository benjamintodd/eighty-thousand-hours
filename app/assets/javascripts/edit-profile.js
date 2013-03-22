$(document).ready( function() {
  // display modal after flash notice is dismissed
  if ($(".flash-modal").find(".modal-body").text() == "Account successfully created.")
  {
    $(".flash-modal").children(".modal-footer").children(".btn").click(showLinkedinModal);
    $(".modal-backdrop").click(showLinkedinModal);
  }
});

function showLinkedinModal()
{
  var signup = $("#linkedin-signup").data("linkedin-signup").toString();
  $.ajax({
    type: 'GET',
    url: '/members/show_linkedin_popup',
    data: 'linkedin_signup=' + signup
  });
}