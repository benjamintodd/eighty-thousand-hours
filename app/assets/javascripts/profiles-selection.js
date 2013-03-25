$(document).ready( function() {
  // set image dimensions to avoid stretching
  // short delay to allow images to load
  setTimeout( function() {
    resizeImages();
  }, 250);

  // since this page takes a long time to load all the images, redo the resize images function to make sure all images are resized correctly
  setTimeout( function() {
    resizeImages();
  }, 500);
  setTimeout( function() {
    resizeImages();
  }, 1000);
});

function resizeImages()
{
  $(".avatar").find("img").each( function() {
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
}