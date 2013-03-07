var fireCount = 0;

$(document).ready( function() {

  // for some reason the ready event is being fired twice
  fireCount++;
  if (fireCount > 1)
  {
    // set background colour to a light grey
    $("body").css('background-color','rgb(233,233,233)');


    // Truncate lists
    var fadeInTime = 800;

    // truncate causes
    $("#causes-list").children("li:gt(7)").hide();
    $("#see-more-causes").click( function(){
      $("#causes-list").children("li:gt(7)").fadeIn(fadeInTime);
      $("#see-more-causes").hide();
    });

    // truncate activities
    $("#activities-list").children("li:gt(7)").hide();
    $("#see-more-activities").click( function(){
      $("#activities-list").children("li:gt(7)").fadeIn(fadeInTime);
      $("#see-more-activities").hide();
    });

    // Truncate positions
    $("#positions").children(".position:gt(2)").hide();
    $("#see-more-positions").click( function() {
      $("#positions").children(".position:gt(2)").fadeIn(fadeInTime);
      $("#see-more-positions").hide();
    });

    // Truncate educations
    $("#educations").children(".education:gt(2)").hide();
    $("#see-more-educations").click( function() {
      $("#educations").children(".education:gt(2)").fadeIn(fadeInTime);
      $("#see-more-educations").hide();
    });

    // truncate donations
    $(".donations").children("ul").children("li:gt(7)").hide();
    $("#see-more-donations").click( function() {
      $(".donations").children("ul").children("li:gt(7)").fadeIn(fadeInTime);
      $("#see-more-donations").hide();
    });


    // display popup box when mouse hovers over member
    var popup_hover = false;
    var config = {
      over: showPopup,
      timeout: 250,   // time until out function is called after cursor moves away
      interval: 300,  // time until over function is called after cursor hovers
      out: hidePopup
    };
    $(".profile-link").hoverIntent(config);
    function showPopup()
    {
      // display popup
      var id = parseInt($(this).closest(".eighty-thousand-hours-profile-condensed-2").attr('id'));
      var left_pos = $(this).offset().left;
      var top_pos = $(this).offset().top;
      var params = "id=" + id + "&left_pos=" + left_pos + "&top_pos=" + top_pos;
      
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

    // don't hide popup if mouse is hovering over it
    $("#profile-popup").hover( function() {
      popup_hover = true
    }, function() {
      popup_hover = false;
      setTimeout( function() {
        $("#profile-popup").hide();
      }, 300);
    });
  }
});