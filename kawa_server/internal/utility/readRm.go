package utility

import (
	"fmt"
	"os"
	"path/filepath"

	directory_utils "github.com/fodedoumbouya/kawa.ai/internal/directory"
)

func ReadSingleMarkdownFile(filename string) (string, error) {
	// Get the current working directory
	// currentDir, err := os.Getwd()
	projectDir, err := directory_utils.FindRootDir("kawa.ai")
	if err != nil {
		fmt.Println("error getting current directory:", err)
		return "", fmt.Errorf("error getting current directory: %v", err)
	}
	projectDir += "/prompts"
	filename = fmt.Sprintf("%s.md", filename)
	// Construct the full path to the file
	filePath := filepath.Join(projectDir, filename)
	// Check if the file exists
	if _, err = os.Stat(filePath); os.IsNotExist(err) {
		return "", fmt.Errorf("file %s does not exist path: %s", filename, filePath)
	}

	// Read the file content
	content, err := os.ReadFile(filePath)
	if err != nil {
		return "", fmt.Errorf("error reading file %s: %v", filename, err)
	}
	return string(content), nil
}
