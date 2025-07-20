package managecreateapplycode

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os/exec"
	"strings"
	"sync"

	"github.com/fodedoumbouya/kawa.ai/internal/action"
	"github.com/fodedoumbouya/kawa.ai/internal/constant"
	directory_utils "github.com/fodedoumbouya/kawa.ai/internal/directory"
	"github.com/fodedoumbouya/kawa.ai/internal/llm"
	"github.com/fodedoumbouya/kawa.ai/internal/model"
	"github.com/fodedoumbouya/kawa.ai/internal/utility"

	git "github.com/fodedoumbouya/kawa.ai/internal/gitManager"

	"github.com/pocketbase/pocketbase/core"
)

// project app_model.AppPlan, userPrompt string, pagePath string
func EditScreen(project model.AppPlan, currentScreen string, prompt string, recordMsgModel *core.Record, App core.App, routers, projectId, apiKey, modelName string, llmType llm.LlmType, msgRecord []*core.Record) error {
	fmt.Println("Edit Screen ", project.AppName, currentScreen, prompt)
	tree, err := directory_utils.GetDirectory(project.AppName, projectId)
	if err != nil {
		return err
	}
	sturcture, err := json.Marshal(tree)
	if err != nil {
		fmt.Println("Structure Error: ", err)
		return err
	}
	// for the user prompt to have context because each request has no context.
	var userMsgRecord []*core.Record
	for _, v := range msgRecord {
		if v.GetString("role") == "user" {
			userMsgRecord = append(userMsgRecord, v)
		}
	}

	if len(userMsgRecord) > constant.CountEditPromptMemory {
		userMsgRecord = userMsgRecord[len(userMsgRecord)-constant.CountEditPromptMemory:]
	}
	if len(userMsgRecord) > 0 {
		prompt += "\nPrevious messages:\n"
		for _, v := range userMsgRecord {
			prompt += v.GetString("content") + "\n"
		}
	}

	input := preEditInputPrompt(prompt, currentScreen, sturcture)
	// fmt.Println("Input:", input)
	resp, err := llm.RequestToLLM(
		llm.RequestLLMArguments{
			Instruction: llm.AGENT_3_Planning_For_Coder,
			Prompt:      input,
			ModelName:   modelName,
			APIKey:      apiKey,
		}, llmType)
	if err != nil {
		fmt.Println("Error calling single call: ", err)
		return err
	}

	llmResponse, err := processLLMResponse(resp)
	if err != nil {
		fmt.Printf("Failed JSON: %s\n", err)
		return err
	}
	if llmResponse.User.Question != "" {
		fmt.Println("Question:", llmResponse.User.Question)
		recordMsgModel.Set("content", llmResponse.User.Question)
		err = App.Save(recordMsgModel)
		if err != nil {
			fmt.Println("Error saving record:", err)
			return err
		}
		return nil
	}
	packagesReferences := map[string]string{}
	if len(llmResponse.NextAgent.NewPackage) > 0 {
		var wg sync.WaitGroup
		for _, v := range llmResponse.NextAgent.NewPackage {
			packageExists, githubURL := checkPackage(v)
			if packageExists {
				wg.Add(1)
				utility.InstallDependency(v, project.AppName, projectId)
				fmt.Printf("Package exists: %s\n", githubURL)
				go func(v string) {
					defer wg.Done()
					packageInfo := getPackageDetailInfo(githubURL)
					fmt.Println("Package Reference:", v, packageInfo)
					packagesReferences[v] = packageInfo
				}(v)
			} else {
				fmt.Println("Package does not exist")
				return err
			}
		}
		wg.Wait()
	}

	packagesInstalled, err := utility.GetDependenciesList(project.AppName, projectId)
	if err != nil {
		fmt.Println("Error getting dependencies list:", err)
		return err
	}
	fmt.Println("Packages Installed:", packagesInstalled)

	currentScreenCode, err := utility.ReadFileFromLib(llmResponse.NextAgent.CurrentViewScreen, project.AppName, projectId)
	if err != nil {
		fmt.Println("Error reading file:", err)
		return err
	}
	// fmt.Println("Current Screen Code:", currentScreenCode)
	currentScreenReference := map[string]string{
		"fileName": llmResponse.NextAgent.CurrentViewScreen,
		"code":     currentScreenCode,
	}
	fmt.Println("Current Screen Reference:", currentScreenReference)
	referenceFiles := []map[string]string{}

	for _, v := range llmResponse.NextAgent.ReferenceFiles {
		fileCode, err1 := utility.ReadFileFromLib(v, project.AppName, projectId)
		if err1 != nil {
			fmt.Println("Error reading file:", err)
			return err1
		}
		referenceFiles = append(referenceFiles, map[string]string{
			"fileName": v,
			"code":     fileCode,
		})
	}
	fmt.Println("Reference Files:", referenceFiles)

	// prompt string, currentScreenReference map[string]string, sturcture []byte, packagesInstalled []string,referenceFiles map[string]string,newScreen []string,referencePackages map[string]string) string {
	editInput := EditInputPrompt(prompt, currentScreenReference, sturcture, packagesInstalled, referenceFiles, llmResponse.NextAgent.NewScreen, packagesReferences, routers)

	resp, err = llm.RequestToLLM(

		llm.RequestLLMArguments{
			Instruction: llm.AGENT_4_Coding,
			Prompt:      editInput,
			ModelName:   modelName,
			APIKey:      apiKey,
		}, llmType)
	if err != nil {
		fmt.Println("Error calling single call: ", err)
		return err
	}
	fmt.Println("Response:", resp)
	err = action.ApplyModifyAction(resp, project.AppName, projectId)
	if err != nil {
		fmt.Println("Error applying action:", err)
		return err
	}
	recordMsgModel.Set("content", llmResponse.User.UserMessage)

	// commit the git repo for the project and then we can push the changes to the branc
	gitManger, err := git.NewGitManager(project.AppName, projectId)
	if err != nil {
		fmt.Println("Error creating git manager:", err)
	}
	fmt.Println("Git Manager:", gitManger)
	gitManger.CommitChanges(llmResponse.User.UserMessage)

	return nil
}

func getPackageDetailInfo(githubURL string) string {
	gitingestScript, err := directory_utils.FindRootDir("kawa_server")
	if err != nil {
		fmt.Println("Error finding root directory:", err)
		return ""
	}
	gitingestScript += "/pkg/gitingest/main.py"
	fmt.Println("gitingestScript:", gitingestScript)

	// Execute the Python script with arguments
	cmd := exec.Command("python", gitingestScript, githubURL)
	// Capture both stdout and stderr
	var stdout, stderr strings.Builder
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err = cmd.Run()
	if err != nil {
		fmt.Printf("Error executing script: %v\n", err)
		fmt.Printf("Stderr: %s\n", stderr.String())
		return ""
	}

	output := stdout.String()

	// Print the output from the Python script
	// fmt.Println("Output:", string(output))
	return output

}

// get the response from the server which will be html and then we look for (GitHub) and then we look for the git link

// checkPackage checks if a package exists and returns its GitHub URL if found
func checkPackage(packageName string) (bool, string) {
	url := "https://pub.dev/packages/" + packageName
	resp, err := http.Get(url)
	if err != nil {
		fmt.Printf("Error fetching package info: %v\n", err)
		return false, ""
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return false, ""
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		fmt.Printf("Error reading response body: %v\n", err)
		return false, ""
	}

	// Look for GitHub link in the HTML content
	bodyStr := string(body)
	githubIndex := strings.Index(bodyStr, `(GitHub)`) //<p><a class="link" href="https://github.com/
	if githubIndex == -1 {
		return true, "" // Package exists but no GitHub link found
	}
	// fmt.Println("GitHub link found", bodyStr[:githubIndex])

	// // Extract the GitHub URL - this is a simple approach and might need refinement
	endIndex := strings.LastIndex(bodyStr[:githubIndex], `href="https://github.com/`)
	if endIndex == -1 {
		return true, ""
	}
	// fmt.Println("GitHub link found", bodyStr[endIndex:])

	githubURL := bodyStr[endIndex:]
	githubURL = strings.Split(githubURL, `href="`)[1]
	githubURL = strings.Split(githubURL, `" rel="`)[0]

	return true, githubURL
}

func preEditInputPrompt(prompt string, current string, sturcture []byte) string {

	input := fmt.Sprintf(`{
		"prompt": "%s",
		"currentViewScreen": "%s",
		"structure": %v,
		"currentDependencies": [],
		 "newPackage": []
	}`, prompt, current, string(sturcture))
	return input

}

func EditInputPrompt(prompt string, currentScreenReference map[string]string, sturcture []byte, packagesInstalled []string, referenceFiles []map[string]string, newScreen []string, referencePackages map[string]string, routers string) string {

	input := fmt.Sprintf(`{
		"prompt": "%s",
		"structure": %v,
		"routers": "%s",
		"currentViewScreen": "%s",
		"currentDependencies": %s,
		"referenceFiles": %s,
		"newScreen": %s,
		"referencePackages": %s,
	}`, prompt, string(sturcture), routers, currentScreenReference, packagesInstalled, referenceFiles, newScreen, referencePackages)
	return input

}

func parseFileStructure(jsonResponse string) (*model.EditScreenResponse, error) {
	// Clean the JSON response
	cleanedJSON := utility.CleanJSONResponse(jsonResponse)

	// Try to unmarshal the cleaned JSON
	var fileStructure model.EditScreenResponse
	err := json.Unmarshal([]byte(cleanedJSON), &fileStructure)
	if err != nil {
		// If unmarshaling fails, try a more aggressive cleaning approach
		cleanedJSON = utility.AggressiveJSONClean(cleanedJSON)
		err = json.Unmarshal([]byte(cleanedJSON), &fileStructure)
		if err != nil {
			return nil, fmt.Errorf("failed to parse JSON after cleaning: %v", err)
		}
	}

	return &fileStructure, nil
}

// Usage in your code would be:
func processLLMResponse(resp string) (*model.EditScreenResponse, error) {
	fileStructure, err := parseFileStructure(resp)
	if err != nil {
		return nil, err
	}
	return fileStructure, nil
}
