var fireCount = 0;

$(document).ready( function() {
  // for some reason ready event is being fired twice
  fireCount++;
  if (fireCount > 1)
  {
    // set background colour to a light grey
    $("body").css('background-color','rgb(233,233,233)');

    // add white filler objects on left and right side of page
    setTimeout( function() {
      // left side
      $(".need-left-filler").append( function() {
        var height = parseInt($(this).height());
        var paddingTop = parseInt($(this).css('paddingTop'));
        var paddingBottom = parseInt($(this).css('paddingBottom'));

        height = (height + paddingTop + paddingBottom).toString() + "px";

        var top = parseInt($(this).offset().top);
        //var marginTop = parseInt($(this).css('marginTop'));
        //var marginBottom = parseInt($(this).css('marginBottom'));
        
        top = (top).toString() + "px";
        
        return "<div class='left-filler' style='height: " + height + "; top: " + top + ";'></div>";
      });

      // right side
      $(".need-right-filler").append( function() {
        var height = parseInt($(this).height());
        var paddingTop = parseInt($(this).css('paddingTop'));
        var paddingBottom = parseInt($(this).css('paddingBottom'));

        height = (height + paddingTop + paddingBottom).toString() + "px";

        var top = parseInt($(this).offset().top);
        //var marginTop = parseInt($(this).css('marginTop'));
        //var marginBottom = parseInt($(this).css('marginBottom'));
        
        top = (top).toString() + "px";

        var left = parseInt($(this).offset().left);
        var width = parseInt($(this).width());

        left = (left + width + 14).toString() + "px";
        
        return "<div class='right-filler' style='height: " + height + "; top: " + top + "; left: " + left + ";'></div>";
      });
    }, 200); 


    // truncate causes
    $("#causes-list").children("li:gt(3)").hide();
    $("#see-more-causes").click( function(){
      $("#causes-list").children("li:gt(3)").show();
      $("#see-more-causes").hide();
    });

    // truncate activities
    $("#activities-list").children("li:gt(3)").hide();
    $("#see-more-activities").click( function(){
      $("#activities-list").children("li:gt(3)").show();
      $("#see-more-activities").hide();
    });

    // Truncate positions
    $("#positions").children(".position:gt(2)").hide();
    $("#see-more-positions").click( function() {
      $("#positions").children(".position:gt(2)").show();
      $("#see-more-positions").hide();
    });

    // Truncate educations
    $("#educations").children(".education:gt(2)").hide();
    $("#see-more-educations").click( function() {
      $("#educations").children(".education:gt(2)").show();
      $("#see-more-educations").hide();
    });

    // truncate donations
    $(".donations").children("ul").children("li:gt(4)").hide();
    $("#see-more-donations").click( function() {
      $(".donations").children("ul").children("li:gt(4)").show();
      $("#see-more-donations").hide();
    });
  }
});