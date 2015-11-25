class DescriptorController < ApplicationController
  # TODO: Figure out better way to do this
  skip_before_filter  :verify_authenticity_token

  def index
  	#probably a better way to do this...
  	descriptor = Hash.new
  	descriptor[:name] = "Kadi 55-30"
  	descriptor[:description] = "Integration for Hipchat to connect Destiny news and info"
  	descriptor[:key] = "com.test.kadi55-30"
  	descriptor[:links] = {:homepage => "https://mighty-meadow-7891.herokuapp.com/",
  		:self => "https://mighty-meadow-7891.herokuapp.com/descriptor"}
  	
  	descriptor[:capabilities] = {
  		:hipchatApiConsumer => { 
  			:fromName => "Kadi 55-30", 
  			:scopes => ["send_notification", "view_messages", "send_message"]
  		}, 
  		:installable => {
  			:allowGlobal => false,
  			:callbackUrl => "https://mighty-meadow-7891.herokuapp.com/users",
  			:uninstalledUrl => "https://mighty-meadow-7891.herokuapp.com/users"
  		},
      :webhook => {
        :url => "https://mighty-meadow-7891.herokuapp.com/webhook/hello",
        :pattern => "^![hH][eE][lL][lL][oO]",
        :event => "room_message",
        :name => "Hello"
      },
      :webhook => {
        :url => "https://mighty-meadow-7891.herokuapp.com/webhook/test",
        :pattern => "^![tT][eE][sS][tT]",
        :event => "room_message",
        :name => "Test"
      }
  		#:internalChathook
  	}


  	render :json => descriptor.to_json
  end

end