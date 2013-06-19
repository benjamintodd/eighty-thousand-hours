$(document).ready( function() {
  // set image dimensions dynamically to avoid stretching
  // short delay to allow images to load
  setTimeout( function() {
    $(".avatar").find("img").each( function() {
      var img = new Image();
      img.src = $(this).attr('src');

      // set shorter side to maximum so that image fills square without stretching
      if (img.width > img.height)
      {
        $(this).css('height', '100%');
      }
      else
      {
        $(this).css('width', '100%');
      }
    });
  }, 150);
});