# Description:
#   Forwards irc messages to Rocket.Chat.
#

# Parameters
dstip = "172.17.0.1:3000"
baseurl = "http://#{dstip}/api"
botusername = "yourbotname"
botuserpw = "yourbotpw"
loginrooms = [
  {"ircroom": "#ircroom1"
  "rcroom": "rocketchatroom1"},
  {"ircroom": "#ircroom2"
  "rcroom": "rocketchatroom2"},
  "ircroom": "endofroom"
  "rcroom": "endofroom"
             ]

request = require 'request'

module.exports = (robot) ->
  robot.hear /(.*)/i, (msg) ->
    # Get Token
    request.post
      url: "#{baseurl}/login"
      form:
        user: "#{botusername}"
        password: "#{botuserpw}"
    , (err, response, body) ->
      throw err if err
      if response.statusCode is not 200
        msg.send "err(get token)"
        exit 1

      logindata = JSON.parse(body)
      token = logindata.data.authToken
      userid = logindata.data.userId

      # Get Rooms
      request
        url: "#{baseurl}/publicRooms"
        headers:
          'X-Auth-Token': token
          'X-User-Id': userid
      , (err, response, body) ->
        throw err if err
        if response.statusCode is not 200
          msg.send "err(get rooms)"
          exit 1

        userroom = msg.message.user.room
        for roominfo, roomindex in loginrooms
          if roominfo['ircroom'] is userroom
            break

        roomdata = JSON.parse(body)
        for room, index in roomdata.rooms
          if room.name is loginrooms[roomindex]["rcroom"]
            roomid = room._id
            break

        # Join Room
        request.post
          url: "#{baseurl}/rooms/#{roomid}/join"
          headers:
            'X-Auth-Token': token
            'X-User-Id': userid
        , (err, response, body) ->
          throw err if err
          if response.statusCode is not 200
            msg.send "err(join rooms)"
            exit 1

          # Convert Msg
          Iconv = require('iconv').Iconv
          jis2utf = new Iconv('ISO-2022-JP', 'UTF-8')
          utf_msg = jis2utf.convert(msg.message.text).toString()
          username = msg.message.user.name
          userroom = msg.message.user.room

          # Forward Msg
          request.post
            url: "#{baseurl}/rooms/#{roomid}/send"
            headers:
              'X-Auth-Token': token
              'X-User-Id': userid
            json:
              msg: "#{userroom}: (#{username}) #{utf_msg}"
          , (err, response, body) ->
            throw err if err
            if response.statusCode is not 200
              msg.send "err(forward msg)"
              exit 1

            # Logout
            request
              url: "#{baseurl}/logout"
              headers:
                'X-Auth-Token': token
                'X-User-Id': userid
            , (err, response, body) ->
              throw err if err
              if response.statusCode is 200
              else
                msg.send "err(logout)"

