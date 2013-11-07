$(document).ready ->
  $("#feedback-privacy" ).popover
    trigger: "hover"
  item = "accessible"
  categories = ["overall", "original", "practical", "persuasive", "transparent", "accessible", "engaging", "total"]
  for item in categories
    $(".categories #" + item).popover
      trigger: "hover"
      html: true
      content: $(".hover-rubrics #" + item)
    $(".categories #" + item).popover
      trigger: "click"
      html: true
      content: $(".hover-rubrics #" + item)
