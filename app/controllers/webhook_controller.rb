class WebhookController < ApplicationController
  # TODO: Figure out better way to do this
  skip_before_filter  :verify_authenticity_token

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

  def parse
  	puts "In webhook parse, for action: #{params[:action]}"
  	user = User.find_by(:oauth_id => params[:oauth_client_id])

  	if Time.at(user.expires_at) <= Time.now
  		# Token is not valid, need new one
  		user = user.refresh_token
  	end

  	# Send response message to HipChat
  	response = "Sending response to message: #{params[:item][:message][:message]}, from #{params[:item][:message][:from][:name]}"
  	room = user.room_id
  	client = HipChat::Client.new(user.access_token, :api_version => 'v2')
  	client["#{room}"].send('Kadi 55-30', response, :color => 'green', :notify => true)

  	# Thank the nice webhook
  	render :nothing => true, status: :ok
  end

end