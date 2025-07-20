package utility

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/fodedoumbouya/kawa.ai/internal/constant"
	"github.com/fodedoumbouya/kawa.ai/internal/directory"

	"gopkg.in/yaml.v2"
)

type PubSpec struct {
	Name            string                 `yaml:"name"`
	Description     string                 `yaml:"description"`
	Version         string                 `yaml:"version"`
	Dependencies    map[string]interface{} `yaml:"dependencies"`
	DevDependencies map[string]interface{} `yaml:"dev_dependencies"`
}

func GetDependenciesList(projectName, projectId string) ([]string, error) {
	projectName = projectName + "_" + projectId
	filePath, err := directory.FindRootDir("kawa_server")
	if err != nil {
		fmt.Println("Error finding root directory: ", err)
		return []string{}, err
	}
	filePath += fmt.Sprintf("/%s/%s/pubspec.yaml", constant.GeneratedProjectDirectory, projectName)
	// Read the pubspec.yaml file
	yamlFile, err := os.ReadFile(filePath)
	if err != nil {
		fmt.Println("Error reading pubspec.yaml file: ", err)
		return []string{}, err
	}
	// Parse the YAML
	var pubspec PubSpec
	err = yaml.Unmarshal(yamlFile, &pubspec)
	if err != nil {
		fmt.Printf("Error parsing YAML: %v\n", err)
		return []string{}, err
	}
	fmt.Printf("Project: %s\n", pubspec.Name)
	fmt.Printf("Description: %s\n", pubspec.Description)
	fmt.Printf("Version: %s\n", pubspec.Version)
	dependencies := []string{}
	for key := range pubspec.Dependencies {
		dependencies = append(dependencies, key)
	}
	return dependencies, nil

}

func InstallDependency(dependencyName string, projectName, projectId string) error {
	projectName = projectName + "_" + projectId
	rootDir, err := directory.FindRootDir("kawa_server")
	if err != nil {
		fmt.Println("Error finding root directory: ", err)
		return err
	}
	rootDir += fmt.Sprintf("/%s/%s/", constant.GeneratedProjectDirectory, projectName)
	err = os.Chdir(rootDir)
	if err != nil {
		fmt.Println("Error changing directory: ", err)
	}
	cmd := exec.Command("flutter", "pub", "add", dependencyName)
	var stdout, stderr strings.Builder
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr
	err = cmd.Run()
	if err != nil {
		fmt.Printf("Error installing dependency: %v\n", err)
		fmt.Printf("Stderr: %s\n", stderr.String())
		return err
	}
	return nil

}

// lib/pages/homePage.dart

func ReadFileFromLib(pathFromLib string, projectName, projectId string) (string, error) {
	projectName = projectName + "_" + projectId
	filePath, err := directory.FindRootDir("kawa_server")
	if err != nil {
		fmt.Println("Error finding root directory: ", err)
		return "", err
	}

	fmt.Println("pathFromLib: ", pathFromLib)
	fmt.Println("filePath: ", filePath)
	fmt.Println("projectName: ", projectName)
	filePath += fmt.Sprintf("/%s/%s/%s", constant.GeneratedProjectDirectory, projectName, pathFromLib)
	// Read the file
	file, err := os.ReadFile(filePath)
	if err != nil {
		fmt.Println("Error reading file: ",
			err)
		return "", err
	}
	return string(file), nil
}
