package editscreen

import (
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/fodedoumbouya/kawa.ai/internal/llm"
	managecreateapplycode "github.com/fodedoumbouya/kawa.ai/internal/manageCreateApplyCode"
	"github.com/fodedoumbouya/kawa.ai/internal/model"

	"github.com/pocketbase/pocketbase/core"
)

func EditScreenHandler(c *core.RequestEvent) error {
	var requestBody struct {
		ProjectId     string `json:"projectId"`
		CurrentScreen string `json:"currentScreen"`
		Prompt        string `json:"prompt"`
	}
	if err := c.BindBody(&requestBody); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request body"})
	}

	apiKey := c.Request.Header.Get("Llm_key")
	llm_host := c.Request.Header.Get("Llm_host")
	llm_model := c.Request.Header.Get("Llm_model")
	if apiKey == "" || llm_host == "" || llm_model == "" {
		return c.JSON(http.StatusUnauthorized, "llm-key, llm-host and llm_model is required in request header")
	}
	var llmType llm.LlmType
	if llm_host == "Mistral" {
		llmType = llm.Mistral
	} else if llm_host == "Gemini" {
		llmType = llm.Gemini
	} else {
		return c.JSON(http.StatusBadRequest, "llm-host is not supported")
	}

	prompt := requestBody.Prompt
	projectId := requestBody.ProjectId
	if prompt == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Prompt is required"})
	}
	project, err := c.App.FindRecordById("projects", projectId)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	var projectPlan model.AppPlan
	err = json.Unmarshal([]byte(project.GetString("projectStructure")), &projectPlan)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	chatRecord, err := c.App.FindRecordsByFilter("chat",
		fmt.Sprintf("project = '%s'", projectId),
		"-created",
		1,
		0,
	)
	if err != nil {
		fmt.Println("Error getting chat record: ", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	// fmt.Println("Chat Record:", chatRecord)
	if len(chatRecord) == 0 {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Chat not found"})
	}
	chat := chatRecord[0]
	collectionMsg, err := c.App.FindCollectionByNameOrId("message")
	if err != nil {
		// c.JSON(500, gin.H{"error": err.Error()})
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	// fmt.Println("Collection Msg:", collectionMsg)
	recordMsglUser := core.NewRecord(collectionMsg)
	recordMsglUser.Set("chat", chat.Id)
	recordMsglUser.Set("content", prompt)
	recordMsglUser.Set("role", "user")
	// model
	recordMsgModel := core.NewRecord(collectionMsg)
	recordMsgModel.Set("chat", chat.Id)
	recordMsgModel.Set("content", "--:)Genereting(53635")
	recordMsgModel.Set("role", "model")
	// save
	err = c.App.Save(recordMsglUser)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	err = c.App.Save(recordMsgModel)
	if err != nil {

		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}
	resp := managecreateapplycode.EditScreen(projectPlan, requestBody.CurrentScreen, prompt, recordMsgModel, c.App, project.GetString("routers"), project.Id, apiKey, llm_model, llmType)
	if resp != nil {
		c.App.Delete(recordMsgModel)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": resp.Error()})

	}

	err = c.App.Save(recordMsgModel)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": err.Error()})
	}

	return c.JSON(http.StatusOK, resp)
}
