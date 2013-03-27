$(document).ready( function() {
  // set delay time for fade in after fading out
  var delay = 450;

  // 'yes' form action for linking question
  $("#btn-linkedin-linking-yes").click( function() {
    // fade out text and buttons 
    fadeOut('slow');

    // create html for new buttons
    var new_yes_html = "<a href='/authentications/linkedin_getprofile_and_link_account' class='btn btn-info btn-confirm form-close' id='btn-linkedin-profile-yes'>Pull profile</a>";
    var new_no_html = "<a href='/authentications/linkedin_signup?linking=true' class='btn btn-success btn-reject form-close' id='btn-linkedin-profile-no'>No thanks</a>";
    
    // get new text from profile text
    var new_p_text = $("#profile").find("p").text();
    
    // replace html of current buttons with new html, after fading out is complete
    setTimeout( function() {
      $("#linking").find("p").text(new_p_text);
      $("#btn-linkedin-linking-yes").replaceWith(new_yes_html);
      $("#btn-linkedin-linking-no").replaceWith(new_no_html);

      // hide new buttons
      $("#btn-linkedin-profile-yes").hide();
      $("#btn-linkedin-profile-no").hide();
    }, delay);

    // fade in changed buttons after fading out is complete
    setTimeout( function() {
      fadeIn('slow');
    }, delay);
  });

  // 'no' form action for linking question
  $("#btn-linkedin-linking-no").click( function() {
    // fade out text and buttons
    fadeOut('slow');

    // get new text from profile text
    var new_p_text = $("#profile").find("p").text();

    // replace text and buttons html after fading out is complete
    setTimeout( function() {
      $("#linking").find("p").text(new_p_text);

      // use hidden profile buttons to get new html
      $("#btn-linkedin-linking-yes").replaceWith($("#btn-linkedin-profile-yes"));
      $("#btn-linkedin-linking-no").replaceWith($("#btn-linkedin-profile-no"));

      // hide new buttons
      $("#btn-linkedin-profile-yes").hide();
      $("#btn-linkedin-profile-no").hide();
    }, delay);

    // fade in after fading out is complete
    setTimeout( function() {
      fadeIn('slow');
    }, delay);
  });
});

function fadeOut(param)
{
  $("#linking").find("p").fadeOut(param);
  $("#linking").find(".btn").fadeOut(param);
}
function fadeIn(param)
{
  $("#linking").find("p").fadeIn(param);
  $("#linking").find(".btn").fadeIn(param);
}