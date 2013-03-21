$(document).ready( function() {
  // animate search form when advanced search is
  $("#advanced-search").click( function() {
    $(this).fadeOut(300);
    $(".button").hide();

    // animation occurs within 700 milliseconds
    var time  = 700;

    // show and animate hidden elements of form
    $(".hidden").show();
    $(".hidden input").offset({top: 0});
    $(".hidden label").offset({top: 0});
    $(".hidden input").animate({top: 0}, time);
    $(".hidden label").animate({top: 0}, time);

    // change dimensions of search form and shift up slightly
    $(".search-form").animate({
      width: 360,
      height: 305
    }, time);

    // button behaves strangely during animation so hide it and then fade it back in
    setTimeout( function() {
      $(".button").css('margin-left', '120px');
      $(".button").css('top', '5px');
      $(".button").fadeIn(500);
    }, 500);
  });
});