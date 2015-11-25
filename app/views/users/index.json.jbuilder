json.array!(@users) do |user|
  json.extract! user, :id, :oauth_id, :secret, :access_token, :expires_in
  json.url user_url(user, format: :json)
end
