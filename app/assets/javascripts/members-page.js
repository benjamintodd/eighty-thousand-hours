var fireCount2 = 0;
$(document).ready( function() {
  fireCount2++;
  if (fireCount2 > 1)
  {
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
  }
});

function showLoadingIcon()
{
  var loading_html = "<div class='loading-icon'><img src='/assets/images/load.gif'></img></div>";
  $(loading_html).insertBefore("#members-list");
  $("#members-list").hide();
}