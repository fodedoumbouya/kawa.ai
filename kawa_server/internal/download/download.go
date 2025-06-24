package download

import (
	"archive/zip"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"

	directory_utils "github.com/fodedoumbouya/kawa.ai/internal/directory"

	"github.com/pocketbase/pocketbase/core"
)

// zipFolder creates a zip file from the specified folder
func zipFolder(folderPath, zipPath string) error {
	// Create zip file
	zipFile, err := os.Create(zipPath)
	if err != nil {
		return err
	}
	defer zipFile.Close()

	// Create zip writer
	zipWriter := zip.NewWriter(zipFile)
	defer zipWriter.Close()

	// Walk through the folder
	err = filepath.Walk(folderPath, func(filePath string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// Skip directories
		if info.IsDir() {
			return nil
		}

		// Create relative path for zip entry
		relPath, err := filepath.Rel(folderPath, filePath)
		if err != nil {
			return err
		}

		// Create zip entry
		zipEntry, err := zipWriter.Create(relPath)
		if err != nil {
			return err
		}

		// Open source file
		srcFile, err := os.Open(filePath)
		if err != nil {
			return err
		}
		defer srcFile.Close()

		// Copy file content to zip entry
		_, err = io.Copy(zipEntry, srcFile)
		return err
	})

	return err
}

// downloadHandler handles the zip download request
func DownloadHandler(projectName, projectId string, c *core.RequestEvent) error {
	if projectName == "" || projectId == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "projectName and projectId are required"})
	}

	projectName = projectName + "_" + projectId

	rootDir, err := directory_utils.FindRootDir("go_manage")
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Internal Server Error"})
	}
	rootDir += "/third_party/" + projectName
	// Check if folder exists
	fmt.Println("rootDir: ", rootDir)
	if _, err = os.Stat(rootDir); os.IsNotExist(err) {
		fmt.Println("Folder does not exist")
		return c.JSON(http.StatusNotFound, map[string]string{"error": "Folder not found"})
	}

	// Create temporary zip file
	tempZipPath := filepath.Join(os.TempDir(), fmt.Sprintf("download_%d.zip", os.Getpid()))
	defer os.Remove(tempZipPath) // Clean up temp file
	fmt.Println("tempZipPath: ", tempZipPath)

	// Create zip file
	err = zipFolder(rootDir, tempZipPath)
	if err != nil {
		fmt.Println("Zip folder error: ", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Internal Server Error"})
	}

	// Open zip file for reading
	zipFile, err := os.Open(tempZipPath)
	if err != nil {
		fmt.Println("Open zip file error: ", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Internal Server Error"})
	}
	defer zipFile.Close()

	// Get file info for content length
	zipInfo, err := zipFile.Stat()
	fmt.Println(zipInfo) // Print file info for debugging
	if err != nil {
		fmt.Println("error getting zip file info,", err)
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Internal Server Error"})
	}

	// Set headers for download
	filename := fmt.Sprintf("%s.zip", projectName)

	c.Response.Header().Set("Content-Type", "application/zip")
	c.Response.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=\"%s\"", filename))
	c.Response.Header().Set("Content-Length", fmt.Sprintf("%d", zipInfo.Size()))

	// Stream zip file to response
	_, err = io.Copy(c.Response, zipFile)
	if err != nil {
		fmt.Println("error copying zip file to response", err)
		return err
	}

	return nil

}
