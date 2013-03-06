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
    }, 100); 


    $("#causes-list").children("li:gt(3)").hide();
    $("#see-more-causes").click( function(){
      $("#causes-list").children("li:gt(3)").show();
      $("#see-more-causes").hide();
    });

    $("#activities-list").children("li:gt(3)").hide();
    $("#see-more-activities").click( function(){
      $("#activities-list").children("li:gt(3)").show();
      $("#see-more-activities").hide();
    });
  }
});