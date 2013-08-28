$(document).ready( function() {
  // get data from ruby to determine whether to call search function
  var redirect = $("#data-search").data("redirect-to-search");
  if (redirect == true)
  {
    var advanced_search = $("#data-search").data("advanced-search");
    $("#form-search").submit();
    if (advanced_search == true)
    {
      // transform into advanced search form
      $("#advanced-search").trigger("click");
      showLoadingIcon();
    }
  }

  // endless page scroll
  $("#members-list").pageless({
    totalPages: 100,
    url: '/members/get_more_members',
    //msgStyles: {'color': '#000000', 'font-size': '1em'},
    //loaderMsg: 'Loading more results',   
    loaderImg: '/images/load.gif',
    distance: '2500'
  });

  // search button
  $("#search-btn").click( function() {
    showLoadingIcon();
  });

  // Add onClick GA tracking to 'read more' links
  // has to be done in JS because link it created via markdown
  $("#members-list .profile-teaser").each( function() {
    var click_event = $(this).find(".heading").find("a").attr("onClick");
    $(this).find(".background").find("a").attr('onClick', click_event);
  });
});

function showLoadingIcon()
{
  var loading_html = "<div class='loading-icon'><img src='/assets/images/load.gif'></img></div>";
  $(loading_html).insertBefore("#members-list");
  $("#members-list").hide();
}