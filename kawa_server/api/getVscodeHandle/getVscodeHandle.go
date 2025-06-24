package redirectvscode

import (
	"fmt"
	"net/http"
	"os"
	"strings"

	directory_utils "github.com/fodedoumbouya/kawa.ai/internal/directory"

	"github.com/pocketbase/pocketbase/core"
)

func GetVscodeUrl(c *core.RequestEvent) error {
	projectId := c.Request.PathValue("projectId")
	if projectId == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "projectId is required"})
	}
	project, err := c.App.FindRecordById("projects", projectId)
	if err != nil {
		return c.JSON(http.StatusBadRequest, fmt.Sprintf("Error finding project: %v", err))
	}

	projectName := project.GetString("projectName") + "_" + projectId

	rootDir, err := directory_utils.FindRootDir("go_manage")
	if err != nil {
		return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error finding root directory: %v", err))
	}
	rootDir += "/third_party/" + projectName
	serverHost := os.Getenv("VSCODE_PREVIEW_HOST")
	if serverHost == "" {
		return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error finding server host: %v", err))
	}
	host := serverHost + "/?folder=" + rootDir
	// check if host doesn't contain http:// then add it
	if !strings.Contains(host, "http://") {
		host = "http://" + host
	}

	return c.JSON(http.StatusOK, map[string]string{"url": host})
}
