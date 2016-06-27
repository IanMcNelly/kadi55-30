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

  def get_rice()
    card = '{
      "style": "image",
      "id": "172fe15d-d72e-4f78-8712-0ec74e7f9aa3",
      "url": "http://i.imgur.com/CcBjOSZ.png",
      "title": "I JUST WANT YOU TO BE PROUD OF ME",
      "thumbnail": {
        "url": "http://i.imgur.com/CcBjOSZ.png",
        "url@2x": "http://i.imgur.com/CcBjOSZ.png",
        "width": 356,
        "height": 260
      }
    }'.to_json
    response = "<img src=\"http://i.imgur.com/CcBjOSZ.png\">"
    [card, response]
  end

  def get_coupa_user(user_login)
    # Query coupa for userID based on login
    url = "#{@user.instance}/api/users?login=#{user_login}"
    query_coupa(url, '//id')
  end

  def get_approvals(message)
    return [nil, "Sending generic response to message: #{message}, Coupa credentials not set"] unless coupa_setup
    message = message.split(' ')
    login = id = nil
    login = message.first.is_a?(Integer) ? nil : message.first
    id = message.first unless login
    offset = message[1] || '0'
    id ||= get_coupa_user(login)

    if id
      # Query Coupa for approvals
      url = "@user.instance/api/approvals?status=pending_approval&position=1&approver-id=#{id}"
      response = query_coupa(url, '//approvals')

      # Parse and send back card
      object = response.at_xpath("//approvable-type")
      approval_id = response.at_xpath('//id')
      object_id = response.at_xpath('//approvable-id')

      card = '{
        "style": "application",
        "url": "https://www.application.com/an-object",
        "format": "medium",
        "id": "db797dasa68-0aff-4ae8-83fc-2e72dbbasd1a707",
        "title": "Sample application card",
        "description": "This is a description of an application object.\nwith 2 lines of text",
        "icon": {
          "url": "http://bit.ly/1S9Z5dF"
        },
        "attributes": [
          {
            "label": "attribute1",
            "value": {
              "label": "value1"
            }
          },
          {
            "label": "attribute2",
            "value": {
              "icon": {
                "url": "http://bit.ly/1S9Z5dF"
              },
              "label": "value2",
              "style": "lozenge-complete"
            }
          }
        ]
      }'.to_json

    end

    
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
    @user = User.find_by(oauth_id: params[:oauth_client_id])
    message = params[:item][:message][:message]
    sender = params[:item][:message][:from][:name]
    if Time.at(@user.expires_at) <= Time.now
      # Token is not valid, need new one
      @user = @user.refresh_token
    end
    room = @user.room_id
    @client = HipChat::Client.new(@user.access_token, api_version: 'v2')
    destiny = Destiny::Client.new(destiny_api_token)
    response = card = nil
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
    when 'rice'
      formatted_card, response = get_rice
      color = 'red'
    when 'approvals'
      formatted_card, response = get_approvals(message)
    else
      puts "EXCEPTION! INVALID HOOKNAME: #{params[:hookname]}"
      @client[room.to_s].send('ERR', "EXCEPTION! INVALID HOOKNAME: #{params[:hookname]}", color: 'red', notify: true)
      render nothing: true, status: :bad_request
    end

    response ||= "Sending generic response to message: #{message}, from #{sender}"
    # Send response message to HipChat
    @client[room.to_s].send('', response, color: color, notify: true, card: formatted_card)

    # Thank the nice webhook
    render nothing: true, status: :ok
  end

  private

  def destiny_api_token
    ENV.fetch('DESTINY_API_KEY', 'abc123')
  end

  def query_coupa(url, xpath)
    c = Curl::Easy.new(url)
    c.headers["accept"] = "application/xml"
    c.headers["x-coupa-api-key"] = "#{@user.coupa_api_key}"
    c.http_get()
    puts "Code is: #{c.response_code}"

    if c.response_code != 200
      puts "Bad request!"
      puts "c.body"
      return
    end

    parsed_response = Nokogiri::XML(c.body)
    value = parsed_response.at_xpath(xpath).content
    value
  end

  def coupa_setup
    return true unless @user.instance.nil? && @user.coupa_api_key.nil?
    card = {
      style: 'application',
      format: 'medium',
      id: "getcoupainfo-from-room-#{@user.room_id}",
      title: "Coupa Instance Information Missing for Room #{@user.room_id}",
      description: {
        format: 'html',
        value: 'This integration requires you to populate the Coupa instance and API key for this instance. Please populate using the dialog <a href=\'#\' data-target=\'kadi.coupa-credentials\'>Here</a>'
      }
    }
    @client[@user.room_id.to_s].send('', "Please rds to use this featur", notify: true, card: card, color: 'random')
    return false
  end

end
