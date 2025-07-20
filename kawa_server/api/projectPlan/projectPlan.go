package projectplan

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	llm "github.com/fodedoumbouya/kawa.ai/internal/llm"
	mfs "github.com/fodedoumbouya/kawa.ai/internal/manageCreateApplyCode"
	pbdbutil "github.com/fodedoumbouya/kawa.ai/internal/pbDbUtil"
	"github.com/fodedoumbouya/kawa.ai/internal/utility"

	app_model "github.com/fodedoumbouya/kawa.ai/internal/model"

	projectProgess "github.com/fodedoumbouya/kawa.ai/internal/projectProgressState"

	"github.com/pocketbase/pocketbase/core"
)

func GetProjectPlan(c *core.RequestEvent) error {
	project, err := pbdbutil.GetProjectPlanData(c)
	if err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": err.Error()})
	}
	return c.JSON(http.StatusOK, project)
}

func CreateProject(c *core.RequestEvent) error {
	// create project plan
	var requestBody struct {
		Prompt string `json:"prompt"`
	}
	if err := c.BindBody(&requestBody); err != nil {
		return c.JSON(http.StatusBadRequest, fmt.Sprintf("Invalid request body: %v", err))
	}

	// llm_key from header
	apiKey := c.Request.Header.Get("Llm_key")
	llm_host := c.Request.Header.Get("Llm_host")
	llm_model := c.Request.Header.Get("Llm_model")
	if apiKey == "" || llm_host == "" || llm_model == "" {
		return c.JSON(http.StatusUnauthorized, "llm-key, llm-host and llm_model is required in request header")
	}
	var llmType llm.LlmType
	switch llm_host {
	case "Mistral":
		llmType = llm.Mistral
	case "Gemini":
		llmType = llm.Gemini
	default:
		// fmt.Println("llm-host is not supported")
		return c.JSON(http.StatusBadRequest, "llm-host is not supported")
	}

	prompt := requestBody.Prompt
	if prompt == "" {
		// c.JSON(400, gin.H{"error": "Prompt is required"})
		return c.JSON(http.StatusBadRequest, "Prompt is required")
	}
	userRecord, err := pbdbutil.GetUserFromToken(c)
	if err != nil {
		// fmt.Println("Error getting user from token: ", err)
		return c.JSON(http.StatusBadRequest, "Error getting user from token")
	}

	// send project progress
	projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.CreatingProjectPlan)

	resp, err := llm.RequestPlanManager(
		llm.RequestLLMArguments{
			Instruction: llm.AGENT_1_Product_Manager_No_Backend,
			Prompt:      prompt,
			ModelName:   llm_model,
			APIKey:      apiKey,
		},

		llmType)
	if err != nil {
		if strings.Contains(err.Error(), "400") {
			return c.JSON(http.StatusBadRequest, "API is not authorized")
		}
		// fmt.Println("Error requesting plan manager: ", err)
		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToCreateProjectPlan)
		return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error requesting plan manager: %v", err))
	}
	// send project progress
	projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.CreatedProjectPlan)
	var appPlan app_model.AppPlan
	err = json.Unmarshal([]byte(resp), &appPlan)
	if err != nil {
		fmt.Printf("Failed to unmarshal response: %s\n", resp)
		return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error unmarshalling response: %v", err))
	}
	// send project progress

	projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.CreatedProjectPlan)

	host, projectId, err := mfs.CreateProjectStructure(appPlan, c)
	if err != nil {
		fmt.Println("Error creating project structure: ", err)
		return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error creating project structure: %v", err))
	}

	return c.JSON(http.StatusOK, map[string]string{"projectId": projectId, "host": host})

}

func DeleteProject(c *core.RequestEvent) error {
	projectId := c.Request.PathValue("projectId")
	project, err := c.App.FindRecordById("projects", projectId)
	if err != nil {
		return c.JSON(http.StatusBadRequest, fmt.Sprintf("Error finding project: %v", err))
	}
	projectName := project.GetString("projectName")

	chatRecord, _ := c.App.FindRecordsByFilter("chat",
		fmt.Sprintf("project = '%s'", projectId),
		"-created",
		1,
		0,
	)
	err = c.App.Delete(project)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error deleting project: %v", err))
	}

	err = closeProject(projectId, c)
	if err != nil {
		fmt.Println("Error deleting project: ", err)
	}
	if len(chatRecord) > 0 {
		messageRecord, _ := c.App.FindRecordsByFilter("message",
			fmt.Sprintf("chat = '%s'", chatRecord[0].Id),
			"-created",
			10000000,
			0,
		)
		c.App.Delete(chatRecord[0])
		if len(messageRecord) > 0 {
			for _, message := range messageRecord {
				c.App.Delete(message)

			}
		}

	}

	// delete project in directory
	err = utility.DeleteFolder(projectName, project.BaseModel.Id)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error deleting project: %v", err))
	}
	return c.JSON(http.StatusOK, "Project deleted")
}

func RunProject(c *core.RequestEvent) error {
	projectId := c.Request.PathValue("projectId")
	collectionHost, err := c.App.FindCollectionByNameOrId("project_address")
	if err != nil {
		return c.JSON(http.StatusBadRequest, fmt.Sprintf("Error finding collection: %v", err))
	}
	hostExist, _ := c.App.FindRecordsByFilter("project_address",
		fmt.Sprintf("project = '%s'", projectId),
		"-created",
		10, // limit
		0,  // offset
	)

	if len(hostExist) > 0 {
		host := hostExist[0].GetString("url")
		isInUsing := utility.IsAppInUse(host)
		if isInUsing {
			return c.JSON(http.StatusBadRequest, host)
		}
		err = c.App.Delete(hostExist[0])
		if err != nil {
			return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error deleting host record: %v", err))
		}

	}
	project, err := c.App.FindRecordById("projects", projectId)
	if err != nil {
		return c.JSON(http.StatusBadRequest, fmt.Sprintf("Error finding project: %v", err))
	}

	host, pid, err := utility.RunDartApp(project.GetString("projectName"), project.BaseModel.Id)
	if err != nil {

		userRecord, err := pbdbutil.GetUserFromToken(c)
		if err != nil {
			fmt.Println("Error getting user from token: ", err)
			return c.JSON(http.StatusBadRequest, "Error getting user from token")
		}
		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToLaunchProject)

		return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error launching project: %v", err))
	}

	recordHost := core.NewRecord(collectionHost)
	recordHost.Set("project", projectId)
	recordHost.Set("url", host)
	recordHost.Set("pid", pid)
	err = c.App.Save(recordHost)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error saving host record: %v", err))
	}
	return c.JSON(http.StatusOK, host)

}

func closeProject(projectId string, c *core.RequestEvent) error {
	hostExist, _ := c.App.FindRecordsByFilter("project_address",
		fmt.Sprintf("project = '%s'", projectId),
		"-created",
		10, // limit
		0,  // offset
	)
	if len(hostExist) > 0 {
		host := hostExist[0].GetString("url")
		isInUsing := utility.IsAppInUse(host)
		if isInUsing {
			pid := hostExist[0].GetString("pid")
			pidInd, err := strconv.Atoi(pid)
			if err != nil {
				return err
			}
			utility.TerminateApp(pidInd)
		}
		err := c.App.Delete(hostExist[0])
		if err != nil {
			return err
		}
		return nil
	}
	return nil
}

// close project and delete project record
func CloseProject(c *core.RequestEvent) error {
	projectId := c.Request.PathValue("projectId")
	hostExist, _ := c.App.FindRecordsByFilter("project_address",
		fmt.Sprintf("project = '%s'", projectId),
		"-created",
		10, // limit
		0,  // offset
	)
	if len(hostExist) > 0 {
		host := hostExist[0].GetString("url")
		isInUsing := utility.IsAppInUse(host)
		if isInUsing {
			pid := hostExist[0].GetString("pid")
			pidInd, err := strconv.Atoi(pid)
			if pid == "0" || pid == "" {
				port := host[strings.LastIndex(host, ":")+1:]
				pidInd, _ = utility.ExactPidDart(port)
			}

			if err != nil {
				return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error converting pid to int: %v", err))
			}
			err = utility.TerminateApp(pidInd)
			if err != nil {
				return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error terminating app: %v", err))
			}
		}
		err := c.App.Delete(hostExist[0])
		if err != nil {
			return c.JSON(http.StatusInternalServerError, fmt.Sprintf("Error deleting host record: %v", err))
		}
		return c.JSON(http.StatusOK, "Project closed")
	}
	return c.JSON(http.StatusBadRequest, "Project does not exist")
}

// GetProjectRunningStatus
func GetProjectRunningStatus(c *core.RequestEvent) error {
	projectId := c.Request.PathValue("projectId")
	hostExist, _ := c.App.FindRecordsByFilter("project_address",
		fmt.Sprintf("project = '%s'", projectId),
		"-created",
		10, // limit
		0,  // offset
	)
	if len(hostExist) > 0 {
		host := hostExist[0].GetString("url")
		isInUsing := utility.IsAppInUse(host)
		if isInUsing {
			return c.JSON(http.StatusOK, map[string]any{"running": true, "message": "Project is running"})
		}
		return c.JSON(http.StatusOK, map[string]any{"running": false, "message": "Project is not running"})
	}
	return c.JSON(http.StatusBadRequest, map[string]any{"running": false, "message": "Project does not exist"})
}
