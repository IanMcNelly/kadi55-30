class DialogController < ApplicationController
  # TODO: Figure out better way to do this
  skip_before_filter :verify_authenticity_token

  def coupa_credentials
    @user = User.find_by(oauth_id: params[:oauth_client_id])
  end

  def coupa_approval
    #return form, then API call on form submit to Coupa. Likely need a round trip back to kadi to retrieve user
    # information, such as api key/coupa instance. so Hipchat !approvals -> Kadi -> Kadi query Coupa -> Kadi create
    # card for first approval (currently) send to hipchat -> Hipchat user approve or reject -> Dialog for comment
    # -> Dialog contents to kadi -> Kadi call coupa -> Kadi send response to Hipchat
    # And this assumes that the instance/api key is already set up. Perhaps skip approvals dialog for now, have card
    # button perform direct call to kadi with the approvable and approvable id. Possible to pass in initial card api
    # key and instance? Prevent rount trip?
  end

  def coupa_reject

  end

  def parse
    case params[:dialogname]
    when 'coupa_credentials'
      coupa_credentials
    else
      render nothing: true, status: :bad_request
    end
  end
end