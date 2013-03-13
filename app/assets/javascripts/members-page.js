$(document).ready( function() {
  $("#members-list").pageless({
    totalPages: 100,
    url: '/members/get_more_members',
    //msgStyles: {'color': '#000000', 'font-size': '1em'},
    //loaderMsg: 'Loading more results',   
    loaderImg: '/images/load.gif',
    distance: '2500'
  });
});