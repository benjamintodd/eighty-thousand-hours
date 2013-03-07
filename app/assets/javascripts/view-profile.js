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
    var timeout;
    $(".profile-link").hover( function() {
      // must hover for some time
      timeout = setTimeOut(showPopup($(this)), 2000);
    }, hidePopup());
    function showPopup(element)
    {
      var id = parseInt(element.closest(".eighty-thousand-hours-profile-condensed-2").attr('id'));
      var params = "id=" + id
      $.ajax({
        type: 'GET',
        url: '/members/display_profile_hover_info',
        data: params
      });
    }
    function hidePopup()
    {
      clearTimeout(timeout);
      $("#profile-hover").hide();
    }
  }
});