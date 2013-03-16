$(document).ready( function() {
  // animate search form when advanced search is
  $("#advanced-search").click( function() {
    $(this).fadeOut(300);
    $(".button").hide();

    // animation occurs within 700 milliseconds
    var time  = 700;

    // show and animate hidden elements of form
    $("#hidden-inputs").show();
    $("#hidden-labels").show();
    $("#hidden-inputs").offset({top: 0});
    $("#hidden-labels").offset({top: 0});
    $("#hidden-inputs").animate({top: 0}, time);
    $("#hidden-labels").animate({top: 0}, time);

    // change dimensions of search form and shift up slightly
    $(".search-form").animate({
      width: 360,
      height: 300
    }, time);
    $(".inputs").animate({top: -5}, time);

    // button behaves strangely during animation so hide it and then fade it back in
    setTimeout( function() {
      $(".button").css('margin-left', '130px');
      $(".button").css('top', '-5px');
      $(".button").fadeIn(500);
    }, 500);
  });
});