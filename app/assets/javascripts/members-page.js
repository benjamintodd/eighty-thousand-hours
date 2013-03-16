var fireCount2 = 0;
$(document).ready( function() {
  fireCount2++;
  if (fireCount2 > 1)
  {
    // get data from ruby to determine whether to call search function
    var redirect = $("#data-search").data("redirect-to-search");
    if (redirect == true)
    {
      $.ajax({
        type: 'POST',
        url: '/members/search',
        data: 'test'
      });
    }
    else
    {
      // endless page scroll
      $("#members-list").pageless({
        totalPages: 100,
        url: '/members/get_more_members',
        //msgStyles: {'color': '#000000', 'font-size': '1em'},
        //loaderMsg: 'Loading more results',   
        loaderImg: '/assets/images/load.gif',
        distance: '2500'
      });
    }
  }
});