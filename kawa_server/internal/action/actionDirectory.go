package action

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"github.com/fodedoumbouya/kawa.ai/internal/constant"
	directory_utils "github.com/fodedoumbouya/kawa.ai/internal/directory"
	app_model "github.com/fodedoumbouya/kawa.ai/internal/model"
	"github.com/fodedoumbouya/kawa.ai/internal/utility"
)

func parseFileStructure(jsonResponse string) (*app_model.ResponseFrontCode, error) {
	// Clean the JSON response
	cleanedJSON := utility.CleanJSONResponse(jsonResponse)

	// Try to unmarshal the cleaned JSON
	var fileStructure app_model.ResponseFrontCode
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

func ApplyModifyAction(jsonData string, projectName, projectId string) error {
	projectName = projectName + "_" + projectId

	rootDir, err := directory_utils.FindRootDir("kawa_server")
	if err != nil {
		return err
	}
	rootDir += fmt.Sprintf("/%s/%s", constant.GeneratedProjectDirectory, projectName)
	root, err := parseFileStructure(jsonData)
	if err != nil {
		fmt.Printf("Failed JSON: %s\n", err)
		return err
	}

	fileCode := make(map[string]string)
	for _, file := range root.Files {
		fileCode[file.FileName] = file.Code
		fmt.Println("FileName", file.FileName)
	}
	return ApplyActions(root.Structure, fileCode, rootDir, "")
}

func ApplyActions(root app_model.DirEntryStructure, fileContents map[string]string, basePath string, oldRoot string) error {
	switch root.Action {

	case 1: // Create
		if root.IsDir {
			if err := os.MkdirAll(filepath.Join(basePath, root.Name), 0755); err != nil {
				return err
			}
		} else {
			content, exists := fileContents[root.Name]

			if !exists {
				return fmt.Errorf("content not found for file: %s, oldPath: %s basePath: %s", root.Name, oldRoot, basePath)
			}
			filePath := filepath.Join(basePath, root.Name)
			fmt.Println("filePath", filePath)
			if err := os.WriteFile(filePath, []byte(content), 0644); err != nil {
				return err
			}
		}
	case 2: // Delete
		if err := os.RemoveAll(filepath.Join(basePath, root.Name)); err != nil {
			return err
		}
	case 3: // Update
		if !root.IsDir {
			content, exists := fileContents[root.Name]
			// fmt.Println("content", content)
			// fmt.Println("fileContents", fileContents)
			// fmt.Println("exists", exists, "root.Name", root.Name)
			if !exists {
				return fmt.Errorf("content not found for file: %s, oldPath: %s basePath: %s", root.Name, oldRoot, basePath)
			}

			filePath := filepath.Join(basePath, root.Name)
			fmt.Println("filePath", filePath)
			if err := os.WriteFile(filePath, []byte(content), 0644); err != nil {
				return err
			}
		}
	}

	for _, child := range root.Children {
		childPath := filepath.Join(basePath, root.Name)
		if err := ApplyActions(child, fileContents, childPath, root.Name); err != nil {
			return err
		}
	}

	return nil
}
