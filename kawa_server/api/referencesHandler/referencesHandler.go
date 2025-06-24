package references

import (
	"net/http"

	"github.com/fodedoumbouya/kawa.ai/internal/references"

	"github.com/pocketbase/pocketbase/core"
)

func GetReferences(c *core.RequestEvent) error {

	ref, err := references.GetReferrences(c)
	if err != nil {
		return c.JSON(http.StatusNotFound, map[string]string{"error": "User has no references"})
	}
	return c.JSON(http.StatusOK, ref)

}

func AddReferenceToScreenData(c *core.RequestEvent) error {
	if c.Request.Method != "POST" {
		return c.JSON(http.StatusMethodNotAllowed, map[string]string{"error": "Method not allowed"})
	}
	screenName := c.Request.Header.Get("Screen_name")
	key := c.Request.Header.Get("Key")
	value := c.Request.Header.Get("Value")

	err := references.AddReferenceToScreen(c, screenName, key, value)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error adding reference to screen"})
	}
	return c.JSON(http.StatusOK, map[string]string{"message": "Reference added to screen"})
}

func UpdateScreenReferenceData(c *core.RequestEvent) error {
	if c.Request.Method != "POST" {
		return c.JSON(http.StatusMethodNotAllowed, map[string]string{"error": "Method not allowed"})
	}
	screenName := c.Request.Header.Get("Screen_name")
	key := c.Request.Header.Get("Key")
	value := c.Request.Header.Get("Value")
	err := references.UpdateScreenReference(c, screenName, key, value)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Error updating reference to screen"})
	}
	return c.JSON(http.StatusOK, map[string]string{"message": "Reference updated to screen"})

}
