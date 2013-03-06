$(document).ready( function() {

  // set background colour to a light grey
  $("body").css('background-color','rgb(233,233,233)');

  // 
  setTimeout( function() {
    $(".content").find(".section").append( function() {
      var height = (parseInt($(this).css('height')) + 15).toString() + "px";

      var top = parseInt($(this).offset().top);
      top = (top - 30).toString() + "px";
      
      return "<div class='filler' style='height: " + height + "; top: " + top + ";'></div>";
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
});