package handler

import (
	"go_manager/api/config"
	downloadHandler "go_manager/api/downloadHandler"
	editscreen "go_manager/api/editScreen"
	getVscodeHandle "go_manager/api/getVscodeHandle"
	gitmanagerhandler "go_manager/api/gitManagerHandler"
	projectplan "go_manager/api/projectPlan"
	referenceshandler "go_manager/api/referenceshandler"
	reload "go_manager/internal/hotRestartChannel"
	projectProgess "go_manager/internal/projectProgressState"

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
	apiNoAuth.GET("/subscribe", reload.SubscribeHoReloard)
	apiNoAuth.POST("/reload", reload.SendHotReloadExterne)
	apiNoAuth.GET("/subscribeProjectProgress", projectProgess.SubscribeProjectProgress)
	// download project - no auth required
	apiNoAuth.GET("/download/{projectId}/{Authorization}", downloadHandler.DownloadProject)

	// send Support API Setting
	apiNoAuth.GET("/supportApiSetting", config.SendSupportAPISetting)

}
