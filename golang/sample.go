package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"time"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

/************************************************
 *            Config section start              *
 *         replace with your own values         *
 ************************************************/

var (
	secretKey     = ""   // replace with your own secretKey from the dashboard
	credentialTTL = 3600 // 1 hour
)

/************************************************
 *            Config section finished           *
 ************************************************/

// Response return response
type Response struct {
	PeerId    string `json:"peerId"`
	Timestamp int64  `json:"timestamp"`
	TTL       int    `json:"ttl"`
	AuthToken string `json:"authToken"`
}

func main() {
	e := echo.New()

	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"*"},
		AllowHeaders: []string{"Origin", "X-Requested-With", "Content-Type", "Accept"},
		AllowMethods: []string{http.MethodPost},
	}))

	e.POST("/authenticate", authenticate)

	e.Logger.Fatal(e.Start(":8080"))
}

func authenticate(c echo.Context) error {
	body, err := ioutil.ReadAll(c.Request().Body)
	if err != nil {
		return c.NoContent(http.StatusBadRequest)
	}

	params, err := url.ParseQuery(string(body))
	if err != nil {
		return c.NoContent(http.StatusBadRequest)
	}

	peerId := params.Get("peerId")
	sessionToken := params.Get("sessionToken")

	if checkSessionToken(peerId, sessionToken) {
		unixTimestamp := time.Now().Unix()
		res := Response{
			PeerId:    peerId,
			Timestamp: unixTimestamp,
			TTL:       credentialTTL,
			AuthToken: calculateAuthToken(peerId, unixTimestamp),
		}
		return c.JSON(http.StatusOK, res)
	}

	return c.NoContent(http.StatusUnauthorized)
}

func checkSessionToken(peerId, sessionToken string) bool {
	// Implement checking whether the session is valid or not.
	// Return true if the session token is valid.
	// Return false if it is invalid.
	// ex:
	if peerId == "" {
		return false
	}
	if sessionToken == "" {
		return false
	}
	return true
}

func calculateAuthToken(peerId string, timestamp int64) string {
	message := fmt.Sprintf("%d:%d:%s", timestamp, credentialTTL, peerId)
	hash := hmac.New(sha256.New, []byte(secretKey))
	hash.Write([]byte(message))
	return base64.StdEncoding.EncodeToString(hash.Sum(nil))
}
