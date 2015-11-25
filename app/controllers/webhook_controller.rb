class WebhookController < ApplicationController
  # TODO: Figure out better way to do this
  skip_before_filter  :verify_authenticity_token
  @@bungo = 'ad1d00901ef741baa0bdfeb5d91194c2'
=begin
Parameters: 
{
    "event" => "room_message", "item" => {
        "message" => {
            "date" => "2015-11-25T17:28:04.222982+00:00", "from" => {
                "id" => 940801, "links" => {
                    "self" => "https://api.hipchat.com/v2/user/940801"
                }, "mention_name" => "Ian", "name" => "Ian McNelly", "version" => "00000000"
            }, "id" => "83ac605e-1213-4616-8819-18914b2eb7e1", "mentions" => nil, "message" => "!hest", "type" => "message"
        }, "room" => {
            "id" => 2199252, "links" => {
                "members" => "https://api.hipchat.com/v2/room/2199252/member", "participants" => "https://api.hipchat.com/v2/room/2199252/participant", "self" => "https://api.hipchat.com/v2/room/2199252", "webhooks" => "https://api.hipchat.com/v2/room/2199252/webhook"
            }, "name" => "testingroom", "version" => "MDSUXBK3"
        }
    }, "oauth_client_id" => "ff4cd309-ea9f-4666-8d75-cfb0b300c117", "webhook_id" => 3197662, "webhook" => {
        "event" => "room_message", "item" => {
            "message" => {
                "date" => "2015-11-25T17:28:04.222982+00:00", "from" => {
                    "id" => 940801, "links" => {
                        "self" => "https://api.hipchat.com/v2/user/940801"
                    }, "mention_name" => "Ian", "name" => "Ian McNelly", "version" => "00000000"
                }, "id" => "83ac605e-1213-4616-8819-18914b2eb7e1", "mentions" => nil, "message" => "!hest", "type" => "message"
            }, "room" => {
                "id" => 2199252, "links" => {
                    "members" => "https://api.hipchat.com/v2/room/2199252/member", "participants" => "https://api.hipchat.com/v2/room/2199252/participant", "self" => "https://api.hipchat.com/v2/room/2199252", "webhooks" => "https://api.hipchat.com/v2/room/2199252/webhook"
                }, "name" => "testingroom", "version" => "MDSUXBK3"
            }
        }, "oauth_client_id" => "ff4cd309-ea9f-4666-8d75-cfb0b300c117", "webhook_id" => 3197662
    }
}
=end
	def get_daily(client)
		data = client.daily_report
		message = "<p>Daily Missions as of #{Time.now}:

		\tStory: #{client.activity_search(data['dailyChapterHashes'].first)}
		
		\tCrucible Playlist: #{client.activity_search(data['dailyCrucibleHash'])}

		\tArmsday: #{client.activity_search(data['armsDay']["active"])}</p>"

		message
	end

	def get_nightfall(client)
		data = client.daily_report
		message = "This weeks NightFall is as follows:<br><br>#{client.activity_search(data['nightfall']['specificActivityHash'])}"
		message
	end

	def get_strike(client)
		data = client.daily_report
		message = "This weeks Heroic Strike is as follows:<br><br>#{client.activity_search(data['heroicStrike']['activityBundleHash'])}"
		message
	end

  def parse
  	puts "In webhook parse, for webhook: #{params[:hookname]}"
  	user = User.find_by(:oauth_id => params[:oauth_client_id])
  	message = params[:item][:message][:message]
  	sender = params[:item][:message][:from][:name]
  	if Time.at(user.expires_at) <= Time.now
  		# Token is not valid, need new one
  		user = user.refresh_token
  	end
  	room = user.room_id
  	client = HipChat::Client.new(user.access_token, :api_version => 'v2')
  	destiny = Destiny::Client.new(@@bungo)
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
  		response = "Use !daily, !hello, !help, !item(pending), !light(pending), !nightfall, !strike or !xur. Feedback/issues may be sent to the Hellmouth for processing."
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
  	when "strike"
  		response = get_strike(destiny)
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
  	def get_key
  		key = 'ad1d00901ef741baa0bdfeb5d91194c2'
  		key
  	end

end