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

	private

		def get_token
			puts "In Get Token"
		end

end
