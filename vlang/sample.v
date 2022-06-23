module main

import crypto.hmac
import crypto.sha256
import encoding.base64
import net.http
import net.urllib
import time
import vweb

/************************************************
 *            Config section start              *
 *         replace with your own values         *
 ************************************************/

const (
	secret_key     = 'YourSecretKey' // replace with your own secretKey from the dashboard
	credential_ttl = 3600 // 1 hour
)

/************************************************
 *            Config section finished           *
 ************************************************/

// Response return response
struct Response {
	peer_id    string [json: peerId]
	timestamp  i64    [json: timestamp]
	ttl        int    [json: ttl]
	auth_token string [json: authToken]
}

struct App {
	vweb.Context
}

fn main() {
	vweb.run(&App{}, 8080)
}

// before_request - called before every request(middleware)
pub fn (mut app App) before_request() {
	app.add_header('Access-Control-Allow-Headers', 'Origin; X-Requested-With; Content-Type; Accept')
	app.add_header('Access-Control-Allow-Origin', '*')
	app.add_header('Access-Control-Allow-Methods', 'POST')
}

['/authenticate'; post]
pub fn (mut app App) authenticate() ?vweb.Result {
	query := urllib.parse_query(app.req.data)?

	peer_id := query.get('peerId')
	session_token := query.get('sessionToken')

	if check_session_token(peer_id, session_token) {
		unix_timestamp := time.now().unix_time()

		res := Response{
			peer_id: peer_id
			timestamp: unix_timestamp
			ttl: credential_ttl
			auth_token: calculate_auth_token(peer_id, unix_timestamp)
		}

		return app.json(res)
	}

	app.set_status(http.Status.unauthorized.int(), 'Unauthorized')
	return app.json({
		'status': '401'
	})
}

fn check_session_token(peer_id string, session_token string) bool {
	// Implement checking whether the session is valid or not.
	// Return true if the session token is valid.
	// Return false if it is invalid.
	// ex:
	if peer_id == '' {
		return false
	}
	if session_token == '' {
		return false
	}
	return true
}

fn calculate_auth_token(peer_id string, timestamp i64) string {
	message := '$timestamp:$credential_ttl:$peer_id'
	hash := hmac.new(secret_key.bytes(), message.bytes(), sha256.sum, sha256.block_size)
	return base64.encode(hash)
}
