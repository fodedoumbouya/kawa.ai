package handler

import (
	"github.com/fodedoumbouya/kawa.ai/api/config"
	downloadHandler "github.com/fodedoumbouya/kawa.ai/api/downloadHandler"
	editscreen "github.com/fodedoumbouya/kawa.ai/api/editScreen"
	getVscodeHandle "github.com/fodedoumbouya/kawa.ai/api/getVscodeHandle"
	gitmanagerhandler "github.com/fodedoumbouya/kawa.ai/api/gitManagerHandler"
	projectplan "github.com/fodedoumbouya/kawa.ai/api/projectPlan"
	referenceshandler "github.com/fodedoumbouya/kawa.ai/api/referencesHandler"
	reload "github.com/fodedoumbouya/kawa.ai/internal/hotRestartChannel"
	projectProgess "github.com/fodedoumbouya/kawa.ai/internal/projectProgressState"

	"github.com/pocketbase/pocketbase/apis"
	"github.com/pocketbase/pocketbase/core"
	// "github.com/gin-gonic/gin"
)

func Handler(r *core.ServeEvent) {
	// Routes
	apiNoAuth := r.Router.Group("/api")
	api := r.Router.Group("/api")
	// make it required to have a token
	api.Bind(apis.RequireAuth())

	// api.GET("/ping", func(c *core.RequestEvent) error {
	// 	err := pbdbutil.TestRecord(c)
	// 	if err != nil {
	// 		return c.JSON(401, map[string]string{"error": "Unauthorized"})
	// 	}

	// 	return c.JSON(200, map[string]string{"message": "pong"})
	// })

	api.GET("/project/{projectId}", projectplan.GetProjectPlan)
	api.GET("/runProject/{projectId}", projectplan.RunProject)
	api.GET("/stopProject/{projectId}", projectplan.CloseProject)
	// project running
	api.GET("/projectRunning/{projectId}", projectplan.GetProjectRunningStatus)
	api.POST("/createProject", projectplan.CreateProject)

	// delete project
	api.DELETE("/project/{projectId}", projectplan.DeleteProject)
	api.POST("/editScreen", editscreen.EditScreenHandler)
	api.POST("/git/backward", gitmanagerhandler.HandleMoveBackwardHandler)
	api.POST("/git/forward", gitmanagerhandler.HandleMoveForwardHandler)
	api.POST("/git/status", gitmanagerhandler.HandleGetStatusHandler)

	// get global references
	api.GET("/globalReferences", referenceshandler.GetReferences)
	// add a reference to a screen
	api.POST("/addReferenceToScreen", referenceshandler.AddReferenceToScreenData)
	// update a screen reference
	api.POST("/updateScreenReference", referenceshandler.UpdateScreenReferenceData)

	// // redirect to project plan
	api.GET("/getVscode/{projectId}", getVscodeHandle.GetVscodeUrl)

	//  no auth required on theses
	apiNoAuth.GET("/subscribe/{projectId}", reload.SubscribeHoReloard)
	apiNoAuth.POST("/reload", reload.SendHotReloadExterne)
	apiNoAuth.GET("/subscribeProjectProgress", projectProgess.SubscribeProjectProgress)
	// download project - no auth required
	apiNoAuth.GET("/download/{projectId}/{Authorization}", downloadHandler.DownloadProject)

	// send Support API Setting
	apiNoAuth.GET("/supportApiSetting", config.SendSupportAPISetting)

}
