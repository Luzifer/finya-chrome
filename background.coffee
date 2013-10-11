chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
  image = '48.png'
  if request.image != null
    image = request.image
  
  notify = webkitNotifications.createNotification image, request.title, request.msg
  notify.show()

  #setTimeout(function(){ notify.cancel(); }, 60000);
  sendResponse
    returnMsg: "All good!"
