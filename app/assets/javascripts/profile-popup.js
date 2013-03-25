$(document).ready( function() {
  // set image dimensions to avoid stretching
  // short delay to allow images to load
  setTimeout( function() {
    $("#profile-hover").find(".avatar").find("img").each( function() {
      var img = new Image();
      img.src = $(this).attr('src');

      if (img.width > img.height)
      {
        $(this).css('height', '100%');
      }
      else
      {
        $(this).css('width', '100%');
      }
    });
  }, 20);
});