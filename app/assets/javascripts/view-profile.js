$(document).ready( function() {
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