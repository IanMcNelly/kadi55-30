class WebhookController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def get_daily(client)
    data = client.daily_report
    story = client.activity_search(data['dailyChapterHashes'].first)
    crucible = client.activity_search(data['dailyCrucibleHash'])
    message = "<pre>Daily Missions as of #{Time.now}:

  Story:
	  #{story[:activityName]} - #{story[:activityDescription]}
	  Skulls: #{story[:skulls].join(', ')}

  Crucible Playlist:
    #{crucible[:activityName]} - #{crucible[:activityDescription]}
</pre>"

    # \tArmsday: #{data['armsDay']['active']}</p>"

    message
  end

  def get_nightfall(client)
    nightfall = client.nightfall(false)
    activity = nightfall[:specificActivity]
    skull_pics = ''
    skull_names = ''
    nightfall[:activeSkulls].each do |skull|
      skull_pics += "<td style=\"width:100px\"><img src=\"http://bungie.net/#{skull[:icon]}\"></td>"
      skull_names += "<td style=\"width:100px\">#{skull[:name]}</td>"
    end
    message = "This weeks NightFall is as follows: <br>
		<img src=\"http://bungie.net/#{activity[:pgcrImage]}\"><br>
		#{activity[:activityName]}: #{activity[:activityDescription]}<br>
		<table>#{skull_pics}</tr><tr>#{skull_names}</tr></table>"
    message
  end

  def get_light_level(client, message)
    message = message.split(' ')
    headers = { 'X-API-Key' => destiny_api_token, 'Content-Type' => 'application/json' }
    'Syntax is !light gamertag <characterIndex>' if message.count < 2
    user = message[1]
    character = message[2].nil? ? 0 : message[2].to_i
    puts "in get_light_level for #{user}"
    response = begin
                 client.class.get("/SearchDestinyPlayer/all/#{user}", headers: headers)['Response']
               rescue => e
                 # puts e
                 nil
               end
    puts response
    if response.nil? || response.empty?
      message = "User #{user} not found. Please ensure it is a valid gamertag."
      return message
    end
    response = response.first
    destiny_id = response['membershipId']
    membership_type = response['membershipType']
    user = response['displayName']
    characters = begin
                   client.class.get("/#{membership_type}/Account/#{destiny_id}/Items", headers: headers)['Response']['data']['characters']
                 rescue => e
                   # puts e
                   nil
                 end
    if characters.nil? || characters.empty?
      message = "No characters found for User #{user}"
      return message
    end
    specficic_character = characters[character]['characterBase']
    if specficic_character.nil? || specficic_character.empty?
      message = "User #{user} has only #{characters.count} characters. You requested character ##{character + 1}"
      return message
    end
    message = "User #{user} has a #{client.character_class(specficic_character['classType']).capitalize} with Light Level: #{specficic_character['stats']['STAT_LIGHT']['value']}"
    message
  end

  def get_crucible(client)
    data = client.daily_report
    message = "This weeks Crucible Playlist is as follows:<br><br>#{client.activity_search(data['weeklyCrucible'].first['activityBundleHash'])}"
    message
  end

  def parse
    puts "In webhook parse, for webhook: #{params[:hookname]}"
    Dotenv.load
    user = User.find_by(oauth_id: params[:oauth_client_id])
    message = params[:item][:message][:message]
    sender = params[:item][:message][:from][:name]
    if Time.at(user.expires_at) <= Time.now
      # Token is not valid, need new one
      user = user.refresh_token
    end
    room = user.room_id
    client = HipChat::Client.new(user.access_token, api_version: 'v2')
    destiny = Destiny::Client.new(destiny_api_token)
    response = nil
    color = 'green'
    case params[:hookname]
    when 'daily'
      response = get_daily(destiny)
      color = 'red'
    when 'hello'
      response = "Hello, #{sender}. I am Kadi 55-30, Tower Postmaster. I am here to provide you will all requiste information for your trials as a Guardian. Please execute protocol '!help' for further assistance."
      color = 'green'
    when 'help'
      response = 'Use !daily, !hello, !help, !item(pending), !light gamertag <character-index>, !nightfall, !crucible or !xur. Feedback and issues may be sent to the Hellmouth for processing.'
      color = 'yellow'
    when 'item'
      response = 'help'
      color = 'green'
    when 'light'
      response = get_light_level(destiny, message)
      color = 'yellow'
    when 'nightfall'
      response = get_nightfall(destiny)
      color = 'purple'
    when 'crucible'
      response = get_crucible(destiny)
      color = 'red'
    when 'xur'
      response = "BETA: Xur details are: <br><br> #{destiny.xur(true)}"
      color = 'gray'
    else
      puts "EXCEPTION! INVALID HOOKNAME: #{params[:hookname]}"
      client[room.to_s].send('ERR', "EXCEPTION! INVALID HOOKNAME: #{params[:hookname]}", color: 'red', notify: true)
      render nothing: true, status: :bad_request
    end

    response ||= "Sending generic response to message: #{message}, from #{sender}"
    # Send response message to HipChat
    client[room.to_s].send('', response, color: color, notify: true)

    # Thank the nice webhook
    render nothing: true, status: :ok
  end

  private

  def destiny_api_token
    ENV.fetch('DESTINY_API_KEY', 'abc123')
  end
end
