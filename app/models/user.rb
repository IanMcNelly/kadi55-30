require 'net/http'
require 'uri'

class User < ActiveRecord::Base

	after_create :get_token
	#def initialize(attributes = {})
	#	puts "Got install request: #{attributes.to_json}"
  #  self.oauth_id  = attributes[:oauth_id]
  #  self.secret = attributes[:secret]
    #self.access_token = attributes[:access_token]
    #self.expires_at = attributes[:expires_at]
  #end

  def find_by_oauth(id)
  	user = User.find_by(:oauth_id => id)
  	user
  end

  def refresh_token
  	get_token
  	self
  end

	private
		def get_token
			puts "In Get Token"
			uri = URI.parse("https://api.hipchat.com/v2/oauth/token")
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true if uri.scheme == 'https'
			request = Net::HTTP::Post.new(uri.request_uri)
			request.set_form_data({"grant_type" => "client_credentials", "scope" => "send_notification view_messages send_message"})
			request.basic_auth(self.oauth_id, self.secret)
			response = http.request(request)
			puts "Got response: " + response.body
			response_hash = JSON.parse(response.body).to_hash
			puts "Hash: " + response_hash.to_s
			self.access_token = response_hash["access_token"]
			self.expires_at = Time.now + response_hash["expires_in"]
			self.save
		end

end
