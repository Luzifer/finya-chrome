last_msg_count = null
last_visitor = null
profile_db = {}

sendDesktopNotification = (title, message, image = null) ->
  chrome.extension.sendRequest
    'msg': message
    'title': title
    'image': image

processInformation = (data) ->
  if data.msgcenter
    if data.msgcenter.num_mails_new > 0 and data.msgcenter.num_mails_new != last_msg_count
      sendDesktopNotification 'Neue Finya-Nachrichten', data.msgcenter.num_mails_new + ' neue Nachrichten'
      chrome.storage.sync.set
        'last_msg_count': data.msgcenter.num_mails_new
    else
      chrome.storage.sync.set
        'last_msg_count': 0

  if data.visits and data.visits.count > 0
    highest_date = last_visitor
    for time, visitor of data.visits.data
      if visitor.ts > last_visitor
        image = null
        from = ''
        if profile_db[visitor.id]
          img = profile_db[visitor.id].picture
          image = "http://static.finya.net/img/u/#{img[0]}/#{img[1]}/#{img}_11.jpg"
          from = " aus #{profile_db[visitor.id].city}"
        sendDesktopNotification 'Neuer Finya-Besucher', "#{visitor.ts_c}: #{visitor.nickname}, #{visitor.age} Jahre#{from}", image
        if visitor.ts > highest_date
          highest_date = visitor.ts
    chrome.storage.sync.set
      'last_visitor': highest_date

  if data.online
    for profile in data.online.data
      profile_db[profile.id] =
        'city': profile.home_city
        'nickname': profile.nickname
        'picture': profile.id_pic
    chrome.storage.local.set
      'profiledb': profile_db
      

pullInformation = () ->
  $.post 'http://www.finya.de/MyFinya/refreshUI/?c=vis,msc,onl', processInformation, 'JSON'

refreshStore = () ->
  chrome.storage.sync.get 'last_msg_count', (data) ->
    if data.last_msg_count
      last_msg_count = data.last_msg_count
    else
      last_msg_count = 0
  chrome.storage.sync.get 'last_visitor', (data) ->
    if data.last_visitor
      last_visitor = data.last_visitor
    else
      last_visitor = 0
  chrome.storage.local.get 'profiledb', (data) ->
    if data.profiledb
      profile_db = data.profiledb

$ ->
  refreshStore()

  chrome.storage.onChanged.addListener (changes, namespace) ->
    for key, value of changes
      if key == 'last_msg_count'
        if value.newValue
          last_msg_count = value.newValue
        else
          last_msg_count = 0
      if key == 'last_visitor'
        if value.newValue
          last_visitor = value.newValue
        else
          last_visitor = 0

  setInterval pullInformation, 20000
