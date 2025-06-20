package downloadhandler

import (
	download "go_manager/internal/download"
	pbdbutil "go_manager/internal/pbDbUtil"
	"net/http"

	"github.com/pocketbase/pocketbase/core"
)

func DownloadProject(c *core.RequestEvent) error {
	token := c.Request.PathValue("Authorization")
	token = token[7:]
	record, err := c.App.FindAuthRecordByToken(token)
	if err != nil {
		return c.JSON(http.StatusNonAuthoritativeInfo, map[string]string{"error": err.Error()})
	}

	project, err := pbdbutil.GetProjectPlanData(c)
	if err != nil {
		return c.JSON(http.StatusNonAuthoritativeInfo, map[string]string{"error looking for the project": err.Error()})
	}
	if project.GetString("user") != record.Id {
		return c.JSON(http.StatusNonAuthoritativeInfo, map[string]string{"error": "You are not the owner of this project"})
	}

	return download.DownloadHandler(project.GetString("projectName"), project.Id, c)

}
