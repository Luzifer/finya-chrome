// Generated by CoffeeScript 1.6.3
(function() {
  chrome.extension.onRequest.addListener(function(request, sender, sendResponse) {
    var image, notify;
    image = '48.png';
    if (request.image !== null) {
      image = request.image;
    }
    notify = webkitNotifications.createNotification(image, request.title, request.msg);
    notify.show();
    return sendResponse({
      returnMsg: "All good!"
    });
  });

}).call(this);
