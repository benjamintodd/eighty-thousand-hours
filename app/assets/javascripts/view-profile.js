$(document).ready( function() {
  
  // set background colour to a light grey
  $("body").css('background-color','rgb(233,233,233)');

  var full_height = $(".container").children("#content").children(".row").children(".span12").css('height');
  $(".filler").css('height',full_height);

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