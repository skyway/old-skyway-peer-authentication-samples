using System;
using System.ComponentModel.DataAnnotations;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace dotnet.Controllers
{
    public class PostBody
    {
        [Required]
        public String peerId { get; set; }

        [Required]
        public string sessionToken { get; set; }
    }

    public class Authenticate
    {
        public String peerId { get; set; }

        public double timestamp { get; set; }

        public int ttl { get; set; }

        public string authToken { get; set; }
    }

    [ApiController]
    [Route("[controller]")]
    public class AuthenticateController : ControllerBase
    {
        private readonly ILogger<AuthenticateController> _logger;

        /************************************************
         *            Config section start              *
         *         replace with your own values         *
         ************************************************/
        private readonly string secretKey = "YourSecretKey"; // replace with your own secretKey from the dashboard
        private readonly int credentialTTL = 3600; // 1 hour

        /************************************************
         *            Config section finished           *
         ************************************************/

        public AuthenticateController(ILogger<AuthenticateController> logger)
        {
            _logger = logger;
        }

        [HttpPost]
        public ActionResult<Authenticate> Post([FromForm] PostBody body)
        {
            if (checkSessionToken(body.peerId, body.sessionToken))
            {
                var unixTimestamp = Math.Floor(DateTime.UtcNow.Subtract(DateTime.UnixEpoch).TotalSeconds);
                return new Authenticate()
                {
                    peerId = body.peerId,
                    timestamp = unixTimestamp,
                    ttl = credentialTTL,
                    authToken = calculateAuthToken(body.peerId, unixTimestamp)
                };
            }
            else
            {
                return StatusCode(401);
            }
        }

        private Boolean checkSessionToken(string peerId, string token)
        {
            // Implement checking whether the session is valid or not.
            // Return true if the session token is valid.
            // Return false if it is invalid.
            return true;
        }

        private string calculateAuthToken(string peerId, double timestamp)
        {
            using (HMACSHA256 hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secretKey)))
            {
                var sign = $"{timestamp.ToString()}:{credentialTTL.ToString()}:{peerId}";
                var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(sign));
                return Convert.ToBase64String(hash);
            }
        }
    }
}
