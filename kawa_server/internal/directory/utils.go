package directory

import (
	"os"
	"path/filepath"
)

const (
	Ignore int = 0
	Create int = 1
	Delete int = 2
	Update int = 3
)

// DirEntry represents a directory or file structure.
type DirEntry struct {
	Name     string     `json:"name"`
	IsDir    bool       `json:"isDir"`
	Action   int        `json:"action"`
	Children []DirEntry `json:"children,omitempty"`
}

// findRootDir navigates up the directory hierarchy until it finds the specified directory.
func FindRootDir(targetDir string) (string, error) {
	currentDir, err := os.Getwd()
	if err != nil {
		return "", err
	}

	for {
		if filepath.Base(currentDir) == targetDir {
			return currentDir, nil
		}

		parentDir := filepath.Dir(currentDir)
		if parentDir == currentDir { // Reached the root directory
			return "", os.ErrNotExist
		}
		currentDir = parentDir
	}
}

// buildDirTree recursively builds the directory structure starting from the given path.
func buildDirTree(path string) (DirEntry, error) {
	root := DirEntry{
		Name:   filepath.Base(path),
		IsDir:  true,
		Action: Ignore,
	}

	entries, err := os.ReadDir(path)
	if err != nil {
		return root, err
	}

	for _, entry := range entries {
		childPath := filepath.Join(path, entry.Name())
		child := DirEntry{
			Name:   entry.Name(),
			IsDir:  entry.IsDir(),
			Action: Ignore,
		}

		if entry.IsDir() {
			childTree, err := buildDirTree(childPath)
			if err != nil {
				return root, err
			}
			child.Children = childTree.Children
		}

		root.Children = append(root.Children, child)
	}

	return root, nil
}

func GetDirectory(projectName, projectId string) (DirEntry, error) {
	projectName = projectName + "_" + projectId
	rootDir, err := FindRootDir("kawa_server")
	if err != nil {
		return DirEntry{}, err
	}

	// gotta find where this function is called from editScreen
	rootDir += "/third_party/" + projectName + "/lib"

	// Build the directory tree from the root directory.
	tree, err := buildDirTree(rootDir)
	return tree, err
}
