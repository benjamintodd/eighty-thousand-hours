var popup_hover = false;

$(document).ready( function() {
  // set background colour to a light grey
  $("body").css('background-color','rgb(233,233,233)');

  // Add tooltip to karma score
  $(".karma").tooltip();

  // set image dimensions dynamically to avoid stretching
  // short delay to allow images to load
  setTimeout( function() {
    $(".avatar").find("img").each( function() {
      var img = new Image();
      img.src = $(this).attr('src');

      // set shorter side to maximum so that image fills square without stretching
      if (img.width > img.height)
      {
        $(this).css('height', '100%');
      }
      else
      {
        $(this).css('width', '100%');
      }
    });
  }, 50);

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
  var config = {
    over: showPopup,
    timeout: 50,   // time until out function is called after cursor moves away
    interval: 0,  // time until over function is called after cursor hovers
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

  // only display other members if page is long enough
  // height of one batch is 320px
  var sidebar_space = $(document).height() - $("#recent-activity").height();
  if (sidebar_space > 1000)
  {
    $("#other-members").show();
    $("#batch-1").show();
  }
  if (sidebar_space > 1700)
  {
    $("#batch-2").show();
  }
  if (sidebar_space > 2000)
  {
    $("#batch-3").show();
  }
});

function showPopup()
{
  // display popup
  var id = parseInt($(this).closest(".eighty-thousand-hours-profile-condensed-2").attr('id'));
  var left_pos = $(this).offset().left;
  var top_pos = $(this).offset().top;
  var params = "id=" + id + "&left_pos=" + left_pos + "&top_pos=" + top_pos + "&page=view_profile";
  
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