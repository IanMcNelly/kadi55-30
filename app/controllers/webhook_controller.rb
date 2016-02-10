class WebhookController < ApplicationController
  # TODO: Figure out better way to do this
  skip_before_filter  :verify_authenticity_token
  @@token = destiny_api_token

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

		#\tArmsday: #{data['armsDay']['active']}</p>"

		message
	end

	def get_nightfall(client)
		
    nightfall = client.nightfall(false)
    activity = nightfall[:specificActivity]
    
		message = "This weeks NightFall is as follows: <br>
		<img src=\"http://bungie.net/#{activity[:pgcrImage]}\"><br>
		#{activity}: #{activity['activityDescription']}<br>
		Skulls: #{nightfall[:activeSkulls].join(', ')}"

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
  	user = User.find_by(:oauth_id => params[:oauth_client_id])
  	message = params[:item][:message][:message]
  	sender = params[:item][:message][:from][:name]
  	if Time.at(user.expires_at) <= Time.now
  		# Token is not valid, need new one
  		user = user.refresh_token
  	end
  	room = user.room_id
  	client = HipChat::Client.new(user.access_token, :api_version => 'v2')
  	destiny = Destiny::Client.new(@@token)
  	response = nil
  	color = 'green'
  	case params[:hookname]
  	when "daily"
  		response = get_daily(destiny)
  		color = 'red'
  	when "hello"
  		response = "Hello, #{sender}. I am Kadi 55-30, Tower Postmaster. I am here to provide you will all requiste information for your trials as a Guardian. Please execute protocol '!help' for further assistance."
  		color = 'green'
  	when "help"
  		response = "Use !daily, !hello, !help, !item(pending), !light(pending), !nightfall, !crucible or !xur. Feedback/issues may be sent to the Hellmouth for processing."
  		color = 'yellow'
  	when "item"
  		response = "help"
  		color = 'green'
  	when "light"
  		response = "help"
  		color = 'yellow'
  	when "nightfall"
  		response = get_nightfall(destiny)
  		color = 'purple'
  	when "crucible"
  		response = get_crucible(destiny)
  		color = 'red'
  	when "xur"
  		response = "BETA: Xur details are: <br><br> #{destiny.xur}"
  		color = 'gray'
  	else
  		puts "EXCEPTION! INVALID HOOKNAME: #{params[:hookname]}"
  		client["#{room}"].send('ERR', "EXCEPTION! INVALID HOOKNAME: #{params[:hookname]}", :color => 'red', :notify => true)
  		render :nothing => true, status: :bad_request
  	end
  	
  	response ||= "Sending generic response to message: #{message}, from #{sender}"
  	# Send response message to HipChat
  	client["#{room}"].send('', response, :color => color, :notify => true)

  	# Thank the nice webhook
  	render :nothing => true, status: :ok
  end

  private
    def destiny_api_token
      ENV.fetch("DESTINY_API_KEY", "abc123")
    end

end