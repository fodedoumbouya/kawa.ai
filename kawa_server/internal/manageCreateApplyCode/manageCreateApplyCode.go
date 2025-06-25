package managecreateapplycode

import (
	"encoding/json"
	"fmt"

	"github.com/fodedoumbouya/kawa.ai/internal/action"
	"github.com/fodedoumbouya/kawa.ai/internal/llm"
	app_model "github.com/fodedoumbouya/kawa.ai/internal/model"
	pbdbutil "github.com/fodedoumbouya/kawa.ai/internal/pbDbUtil"
	"github.com/fodedoumbouya/kawa.ai/internal/utility"

	projectProgess "github.com/fodedoumbouya/kawa.ai/internal/projectProgressState"

	git "github.com/fodedoumbouya/kawa.ai/internal/gitManager"

	"github.com/pocketbase/pocketbase/core"
	// Add these new imports
)

func CreateProjectStructure(project app_model.AppPlan, c *core.RequestEvent) (string, string, error) {

	apiKey := c.Request.Header.Get("Llm_key")
	llm_host := c.Request.Header.Get("Llm_host")
	llm_model := c.Request.Header.Get("Llm_model")
	if apiKey == "" || llm_host == "" || llm_model == "" {
		return "", "", fmt.Errorf("llm-key, llm-host and llm_model is required in request header")
	}
	var llmType llm.LlmType
	if llm_host == "Mistral" {
		llmType = llm.Mistral
	} else if llm_host == "Gemini" {
		llmType = llm.Gemini
	} else {
		fmt.Println("llm-host is not supported")
		return "", "", fmt.Errorf("llm-host is not supported")
	}

	// Get user authentication details
	userRecord, err := pbdbutil.GetUserFromToken(c)
	if err != nil {
		fmt.Println("Error getting user from token: ", err)
		return "", "", fmt.Errorf("error getting user from token: %w", err)
	}

	// Start the project creation process
	projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.CreatingProject)

	// Initialize project record in database
	collection, err := c.App.FindCollectionByNameOrId("projects")
	if err != nil {

		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToCreateProject)

		return "", "", fmt.Errorf("failed to find collection: %w", err)
	}
	// chat collection
	collectionChat, err := c.App.FindCollectionByNameOrId("chat")
	if err != nil {

		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToCreateProject)

		return "", "", fmt.Errorf("failed to find collection: %w", err)

	}
	// host collection
	collectionHost, err := c.App.FindCollectionByNameOrId("project_address")
	if err != nil {

		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToCreateProject)

		return "", "", fmt.Errorf("failed to find collection: %w", err)
	}

	recordProject := core.NewRecord(collection)
	recordProject.Set("user", userRecord.BaseModel.Id)
	recordProject.Set("projectName", project.AppName)

	projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.CreatedingProjectNavigationFlow)
	// Generate navigation flow from screens
	appNavigationModel, err := getAppNavigationFlow(project.User.FrontEnd.Screens, apiKey, llm_model, llmType)
	if err != nil {

		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToCreateProjectNavigationFlow)

		return "", "", fmt.Errorf("navigation flow generation failed: %w", err)
	}

	// Save project metadata
	recordProject.Set("routers", appNavigationModel.AppNavigation.Path)
	recordProject.Set("projectStructure", project)

	// Marshal project components
	components, err := marshalProjectComponents(project, appNavigationModel)
	if err != nil {

		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToCreateProjectStructure)

		return "", "", fmt.Errorf("failed to marshal project components: %w", err)
	}

	// Generate navigation code
	nav, err := generateNavigation(components.screens, components.appNavigationFlow, apiKey, llm_model, llmType)
	if err != nil {

		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToCreateProject)

		return "", "", fmt.Errorf("navigation generation failed: %w", err)
	}

	// Prepare LLM request
	llmJson := prepareLLMRequest(components, nav.Code)
	resp, err := llm.RequestToLLM(

		llm.RequestLLMArguments{
			Instruction: llm.AGENT_1_5_CREATESTRUCTURE_v2,
			Prompt:      llmJson,
			ModelName:   llm_model,
			APIKey:      apiKey,
		}, llmType)
	if err != nil {

		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToCreateProject)
		return "", "", fmt.Errorf("LLM request failed: %w", err)
	}
	projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.CreatedProjectNavigationFlow)

	// Save final project record
	if err = c.App.Save(recordProject); err != nil {
		return "", "", fmt.Errorf("failed to save project record: %w", err)
	}

	// Create and configure Flutter project
	projectProgess.SendProjectProgress(userRecord.Id, projectProgess.CreatingFlutterProject)
	if err = setupFlutterProject(project.AppName, recordProject.Id, nav); err != nil {
		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToCreateFlutterProject)
		c.App.Delete(recordProject)
		utility.DeleteFolder(project.AppName, recordProject.Id)

		return "", "", fmt.Errorf("flutter project setup failed: %w", err)
	}
	projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.CreatedFlutterProject)

	if err = buildNavigation(nav, project.AppName, recordProject.Id); err != nil {
		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToCreateProject)
		c.App.Delete(recordProject)
		utility.DeleteFolder(project.AppName, recordProject.Id)

		return "", "", fmt.Errorf("navigation build failed: %w", err)
	}

	// Apply generated code modifications

	if err = action.ApplyModifyAction(resp, project.AppName, recordProject.Id); err != nil {
		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToCreateProject)
		c.App.Delete(recordProject)

		utility.DeleteFolder(project.AppName, recordProject.Id)
		return "", "", fmt.Errorf("code modification failed: %w", err)
	}

	// Launch the project
	projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.LaunchingProject)
	host, pid, err := utility.RunDartApp(project.AppName, recordProject.BaseModel.Id)
	if err != nil {
		projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.FailedToLaunchProject)
		return "", "", fmt.Errorf("project launch failed: %w", err)
	}
	projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.ProjectLaunched)

	// Add activity monitoring and termination
	// go monitorAppActivity(host, 10*time.Minute, pid)

	// recordChat := core.NewRecord(collectionChat)
	recordChat := core.NewRecord(collectionChat)
	recordChat.Set("title", project.AppName)
	recordChat.Set("project", recordProject.BaseModel.Id)
	//  save chat
	if err = c.App.Save(recordChat); err != nil {
		return "", "", fmt.Errorf("failed to save chat record: %w", err)
	}
	// save host
	recordHost := core.NewRecord(collectionHost)
	recordHost.Set("project", recordProject.BaseModel.Id)
	recordHost.Set("url", host)
	recordHost.Set("pid", pid)
	if err = c.App.Save(recordHost); err != nil {
		return "", "", fmt.Errorf("failed to save host record: %w", err)
	}

	collectionMsg, err := c.App.FindCollectionByNameOrId("message")
	if err == nil {

		recordMsgModel := core.NewRecord(collectionMsg)
		recordMsgModel.Set("chat", recordChat.BaseModel.Id)
		recordMsgModel.Set("content", fmt.Sprintf("I have created %v project, we can start cooking now", project.AppName))
		recordMsgModel.Set("role", "model")
		c.App.Save(recordMsgModel)

	}

	projectProgess.SendProjectProgress(userRecord.BaseModel.Id, projectProgess.CreatedProject)

	// commit the git repo for the project and then we can push the changes to the branc
	gitManger, _ := git.NewGitManager(project.AppName, recordProject.Id)
	gitManger.InitRepo()

	return host, recordProject.Id, nil
}

type projectComponents struct {
	screens           string
	modelStructure    string
	appNavigationFlow string
	structure         string
}

func marshalProjectComponents(project app_model.AppPlan, appNavigationModel interface{}) (*projectComponents, error) {
	screens, err := json.Marshal(project.User.FrontEnd.Screens)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal screens: %w", err)
	}

	modelStructure, err := json.Marshal(project.NextAgent.ModelStructure)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal model structure: %w", err)
	}

	appNavigationFlow, err := json.Marshal(appNavigationModel)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal navigation flow: %w", err)
	}

	structure, err := json.Marshal(firstStructure)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal structure: %w", err)
	}

	return &projectComponents{
		screens:           string(screens),
		modelStructure:    string(modelStructure),
		appNavigationFlow: string(appNavigationFlow),
		structure:         string(structure),
	}, nil
}

func setupFlutterProject(appName, projectId string, nav app_model.File) error {
	if err := utility.CreateFlutterProject(appName, projectId); err != nil {
		return fmt.Errorf("flutter project creation failed: %w", err)
	}

	if err := utility.InstallDependency("go_router", appName, projectId); err != nil {
		return fmt.Errorf("dependency installation failed: %w", err)
	}
	if err := utility.InstallDependency("intl", appName, projectId); err != nil {
		return fmt.Errorf("dependency installation failed: %w", err)
	}

	if err := buildNavigation(nav, appName, projectId); err != nil {
		return fmt.Errorf("navigation build failed: %w", err)
	}

	return nil
}

func prepareLLMRequest(components *projectComponents, navCode string) string {
	return fmt.Sprintf(`{
        "structure": %v,
        "screens": %v,
        "model-structure": %v,
        "appNavigator": %v
    }`, components.structure, components.screens, components.modelStructure, navCode)
}
