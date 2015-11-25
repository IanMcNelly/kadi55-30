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
	def get_daily
		client = Destiny::Client.new(@@bungo)
		data = client.daily_report
		message = "Daily Missions as of #{Time.now}:

		\tStory: #{client.activity_search(data['dailyChapterHashes']).to_s}
		
		\tCrucible Playlist: #{client.activity_search(data['dailyCrucibleHash']).to_s}

		\tArmsday: #{client.activity_search(data['armsDay']["active"])}"

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
  	response = nil
  	color = 'green'
  	case params[:hookname]
  	when "daily"
  		response = get_daily
  	when "hello"
  		response = "Hello, #{name}. I am Kadi 55-30, Tower Postmaster. I am here to provide you will all requiste information for your trials as a Guardian. Please execute protocol '!help' for further assistance."
  	when "help"
  		response = "help"
  	when "item"
  		response = "help"
  	when "light"
  		response = "help"
  	when "nightfall"
  		response = "help"
  	when "strike"
  		response = "help"
  	when "xur"
  		response = "help"
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