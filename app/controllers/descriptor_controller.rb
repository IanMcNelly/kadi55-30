class DescriptorController < ApplicationController

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
  			:callback_url => "https://mighty-meadow-7891.herokuapp.com/users",
  			:uninstalled_url => "https://mighty-meadow-7891.herokuapp.com/users"
  		}
  		#:internalChathook
  	}

  	render :json => descriptor.to_json
  end

end