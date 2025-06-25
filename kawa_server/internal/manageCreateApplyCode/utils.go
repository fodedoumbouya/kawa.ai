package managecreateapplycode

import (
	"encoding/json"
	"fmt"
	"strings"

	"github.com/fodedoumbouya/kawa.ai/internal/action"
	directory_utils "github.com/fodedoumbouya/kawa.ai/internal/directory"
	"github.com/fodedoumbouya/kawa.ai/internal/llm"
	app_model "github.com/fodedoumbouya/kawa.ai/internal/model"
)

// / This function is used to get the navigation flow of the app
// / It takes a list of screens as input and returns the navigation flow of the app
// / calling the LLM to get the navigation flow with 'navigation' instruction
func getAppNavigationFlow(screens []string, apiKey, modelName string, llmType llm.LlmType) (app_model.AppNavigationModel, error) {
	// appNavInstruction, _ := utility.ReadSingleMarkdownFile("navigation")
	appNavigation, err := llm.RequestToLLM(

		llm.RequestLLMArguments{
			Instruction: llm.AGENT_1_4_NAVIGATION,
			Prompt:      fmt.Sprintf(`{"screens": %v}`, screens),
			ModelName:   modelName,
			APIKey:      apiKey,
		}, llmType)
	// SingleCallNoMemory(appNavInstruction, fmt.Sprintf(`{"screens": %v}`, screens), "")
	if err != nil {
		fmt.Println("Error calling single call: ", err, "resp: ", appNavigation)
		return app_model.AppNavigationModel{}, err
	}
	var appNavigationModel app_model.AppNavigationModel

	// err = json.Unmarshal([]byte(appNavigation), &appNavigationModel)
	// if err != nil {
	// 	return app_model.AppNavigationModel{}, err
	// }
	decoder := json.NewDecoder(strings.NewReader(appNavigation))
	decoder.DisallowUnknownFields()

	err = decoder.Decode(&appNavigationModel)
	if err != nil {
		fmt.Printf("Failed JSON: %s\n", appNavigation)
		return app_model.AppNavigationModel{}, err
	}

	return appNavigationModel, nil

}

// / This function is used to build the navigation of the app
// / It takes a list of screens and the app navigation as input and returns the navigation of the app
// / calling the LLM to build the navigation with 'AGENT_Create_Navigation' instruction
func generateNavigation(screens string, appNavig string, apiKey, modelName string, llmType llm.LlmType) (app_model.File, error) {

	data := fmt.Sprintf(`
	{
	"screens": %v,
	"appNavigator": %v
	}`,
		screens, appNavig)

	resp, err := llm.RequestToLLM(

		llm.RequestLLMArguments{
			Instruction: llm.AGENT_Create_Navigation,
			Prompt:      data,
			ModelName:   modelName,
			APIKey:      apiKey,
		}, llmType)
	if err != nil {
		fmt.Println("Error calling single call: ", err, "resp: ", resp)
		return app_model.File{}, err
	}

	// Unmarshal the JSON data into the Root struct
	var navScreen app_model.File
	// First attempt to clean the response
	cleanResp := strings.ReplaceAll(resp, "\\\n", "\\n")

	var err2 error
	err = json.Unmarshal([]byte(cleanResp), &navScreen)
	if err != nil {
		// If simple Unmarshal fails, try more manual approach
		decoder := json.NewDecoder(strings.NewReader(cleanResp))
		decoder.DisallowUnknownFields()

		err2 = decoder.Decode(&navScreen)
		if err2 != nil {
			fmt.Printf("Failed JSON: %s\n", resp)
			return app_model.File{}, fmt.Errorf("JSON parse error: %v, original error: %v", err2, err)
		}
	}

	return navScreen, nil
}

var firstStructure = app_model.DirEntryStructure{
	Name:   "lib",
	IsDir:  true,
	Action: 0,
	Children: []app_model.DirEntryStructure{
		{
			Name:   "router",
			IsDir:  true,
			Action: 0,
			Children: []app_model.DirEntryStructure{
				{
					Name:   "app_router.dart",
					IsDir:  false,
					Action: 0,
				},
			},
		},
		{
			Name:   "pages",
			IsDir:  true,
			Action: 0,
		},
	},
}

func buildNavigation(navScreen app_model.File, projectName, projectId string) error {
	projectName = projectName + "_" + projectId
	rootDir, err := directory_utils.FindRootDir("kawa_server")
	if err != nil {
		return err
	}
	rootDir += "/third_party/" + projectName

	var root app_model.ResponseFrontCode

	root.Structure = app_model.DirEntryStructure{
		Name:   "lib",
		IsDir:  true,
		Action: 0,
		Children: []app_model.DirEntryStructure{
			{
				Name:   "router",
				IsDir:  true,
				Action: 1,
				Children: []app_model.DirEntryStructure{
					{
						Name:   "app_router.dart",
						IsDir:  false,
						Action: 1,
					},
				},
			},
			{
				Name:   "pages",
				IsDir:  true,
				Action: 1,
			},
		},
	}
	root.Files = append(root.Files, app_model.File{
		FileName: navScreen.FileName,
		FilePath: navScreen.FilePath,
		Code:     navScreen.Code,
	})
	fileCode := make(map[string]string)
	for _, file := range root.Files {
		fileCode[file.FileName] = file.Code
	}

	return action.ApplyActions(root.Structure, fileCode, rootDir, "")
}
