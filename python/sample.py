import hashlib
import hmac
import time
import json
import cgi

from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import urlparse


################################################
#            Config section start              #
#         replace with your own values         #
################################################

secretKey = 'YourSecretKey' # replace with your own secretKey from the dashboard
credentialTTL = 3600 # 1 hour

#################################################
#            Config section finished            #
#################################################

def main():
    server = HTTPServer(('localhost', 8080), PostHandler)
    print 'Starting server, use <Ctrl-C> to stop'
    server.serve_forever()

def calculate_auth_token(peerId, timestamp):
    message = '{}:{}:{}'.format(timestamp, credentialTTL, peerId)
    print message
    # Generate the hash.
    return hmac.new(
        secretKey,
        message,
        hashlib.sha256
    ).digest().encode("base64").rstrip('\n')

def check_session_token(peer_id, token):
    # Implement checking whether the session is valid or not.
    # Return true if the session token is valid.
    # Return false if it is invalid.
    return True

class PostHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        parsed_path = urlparse.urlparse(self.path)

        if parsed_path.path == '/authenticate':
            length = int(self.headers['Content-Length'])
            postvars = cgi.parse_qs(self.rfile.read(length), keep_blank_values=1)

            unix_timestamp = int(time.time())
            if ('peerId' not in postvars or 'sessionToken' not in postvars):
                self.send_response(400)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                return
            peer_id = postvars['peerId'][0]
            session_token = postvars['sessionToken'][0]

            if check_session_token(peer_id, session_token):
                # Session token check was successful.
                credential = {
                    'peerId': peer_id,
                    'timestamp': unix_timestamp,
                    'ttl': credentialTTL,
                    'authToken': calculate_auth_token(peer_id, unix_timestamp)
                }

                self.rfile.close()
                self.send_response(200)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps(credential))
            else:
                # Session token check failed
                self.send_response(401)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
        else:
            self.send_response(404)
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
        return

if __name__ == "__main__":
    main()