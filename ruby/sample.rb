require 'sinatra'
require 'openssl'
require 'Base64'
require 'JSON'

set :port, 8080


################################################
#            Config section start              #
#         replace with your own values         #
################################################

SECRET_KEY = "YourSecretKey"
CREDENTIAL_TTL = 3600

#################################################
#            Config section finished            #
#################################################

post '/authenticate' do
  headers \
      "Access-Control-Allow-Origin" => "*",
      "Content-Type" => "application/json"

  peer_id = params['peerId']
  session_token = params['sessionToken']

  if peer_id == nil || session_token == nil
    status 400
    return
  end

  if check_session_token(peer_id, session_token)
    # Session token check was successful.
    unix_timestamp = Time.now.to_i

    credential = {
        peerId: peer_id,
        timestamp: unix_timestamp,
        ttl: CREDENTIAL_TTL,
        authToken: calculate_auth_token(peer_id, unix_timestamp)
    }

    body JSON.generate(credential)
  else
    # Session token check failed.
    status 401
  end
end

def check_session_token(peer_id, token)
  # Implement checking whether the session is valid or not.
  # Return true if the session token is valid.
  # Return false if it is invalid.
  true
end

def calculate_auth_token(peer_id, timestamp)
  message = "#{timestamp}:#{CREDENTIAL_TTL}:#{peer_id}"
  hash = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), SECRET_KEY, message)
  Base64.encode64(hash).strip()
end