package gitmanagerhandler

import (
	"fmt"
	"net/http"

	git "github.com/fodedoumbouya/kawa.ai/internal/gitManager"

	"github.com/pocketbase/pocketbase/core"
)

// GitResponse represents the standard response for Git operations
type GitResponse struct {
	Success      bool   `json:"success"`
	Message      string `json:"message,omitempty"`
	CanBackward  bool   `json:"canBackward,omitempty"`
	CanForward   bool   `json:"canForward,omitempty"`
	CurrentState string `json:"currentState,omitempty"`
}

// getGitManager creates a GitManager for the project
func getGitManageHandler(c *core.RequestEvent, projectID string) (*git.GitManager, error) {
	project, err := c.App.FindRecordById("projects", projectID)
	if err != nil {
		return nil, err
	}
	projectName := project.GetString("projectName")
	return git.NewGitManager(projectName, projectID)
}

// HandleCommit handles automatic commits for a project
func HandleCommitHandler(c *core.RequestEvent, message string, projectID string) (error, GitResponse) {

	if message == "" {
		message = "Auto-commit: Project update"
	}

	gitManager, err := getGitManageHandler(c, projectID)
	if err != nil {
		return fmt.Errorf("failed to access project: %v", err), GitResponse{}
	}

	if err := gitManager.AutoCommit(message); err != nil {
		return fmt.Errorf("failed to commit changes: %v", err), GitResponse{}
	}

	canBackward, _ := gitManager.CanMoveBackward()
	canForward, _ := gitManager.CanMoveForward()
	currentCommit, _ := gitManager.GetCurrentCommit()

	resp := GitResponse{
		Success:      true,
		Message:      "Changes committed successfully",
		CanBackward:  canBackward,
		CanForward:   canForward,
		CurrentState: currentCommit,
	}

	return nil, resp
}

// HandleMoveBackward handles moving backward in the project history
func HandleMoveBackwardHandler(c *core.RequestEvent) error {
	if c.Request.Method != http.MethodPost {
		return c.JSON(http.StatusMethodNotAllowed, map[string]string{"error": "Method not allowed"})
	}

	var requestBody struct {
		ProjectID string `json:"projectId"`
	}

	if err := c.BindBody(&requestBody); err != nil {
		// c.JSON(400, gin.H{"error": "Invalid request body"})
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request body"})
	}
	if requestBody.ProjectID == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Project ID is required"})
	}

	gitManager, err := getGitManageHandler(c, requestBody.ProjectID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to access project"})
	}

	canMoveBackward, _ := gitManager.CanMoveBackward()
	if !canMoveBackward {
		resp := GitResponse{
			Success:     false,
			Message:     "Cannot move backward: no history available",
			CanBackward: false,
		}
		return c.JSON(http.StatusBadRequest, resp)
	}

	if err := gitManager.MoveBackward(); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to move backward"})
	}

	// Update status after moving
	canBackward, _ := gitManager.CanMoveBackward()
	canForward, _ := gitManager.CanMoveForward()
	currentCommit, _ := gitManager.GetCurrentCommit()

	resp := GitResponse{
		Success:      true,
		Message:      "Moved backward successfully",
		CanBackward:  canBackward,
		CanForward:   canForward,
		CurrentState: currentCommit,
	}
	return c.JSON(http.StatusOK, resp)
}

// HandleMoveForward handles moving forward in the project history
func HandleMoveForwardHandler(c *core.RequestEvent) error {
	if c.Request.Method != http.MethodPost {
		return c.JSON(http.StatusMethodNotAllowed, map[string]string{"error": "Method not allowed"})
	}

	var req struct {
		ProjectID string `json:"projectId"`
	}

	if err := c.BindBody(&req); err != nil {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request body"})
	}

	if req.ProjectID == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Project ID is required"})
	}

	gitManager, err := getGitManageHandler(c, req.ProjectID)

	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to access project"})
	}

	canMoveForward, _ := gitManager.CanMoveForward()
	if !canMoveForward {
		resp := GitResponse{
			Success:    false,
			Message:    "Cannot move forward: no future state available",
			CanForward: false,
		}
		return c.JSON(http.StatusBadRequest, resp)
	}

	if err := gitManager.MoveForward(); err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to move forward"})
	}

	// Update status after moving
	canBackward, _ := gitManager.CanMoveBackward()
	canForward, _ := gitManager.CanMoveForward()
	currentCommit, _ := gitManager.GetCurrentCommit()

	resp := GitResponse{
		Success:      true,
		Message:      "Moved forward successfully",
		CanBackward:  canBackward,
		CanForward:   canForward,
		CurrentState: currentCommit,
	}

	return c.JSON(http.StatusOK, resp)
}

// HandleGetStatus returns the git status of a project
func HandleGetStatusHandler(c *core.RequestEvent) error {
	if c.Request.Method != http.MethodPost {
		return c.JSON(http.StatusMethodNotAllowed, map[string]string{"error": "Method not allowed"})
	}
	var requestBody struct {
		ProjectID string `json:"projectId"`
	}

	if err := c.BindBody(&requestBody); err != nil {
		// c.JSON(400, gin.H{"error": "Invalid request body"})
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Invalid request body"})
	}
	if requestBody.ProjectID == "" {
		return c.JSON(http.StatusBadRequest, map[string]string{"error": "Project ID is required"})
	}

	gitManager, err := getGitManageHandler(c, requestBody.ProjectID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, map[string]string{"error": "Failed to access project"})
	}

	isRepo := gitManager.IsGitRepo()
	var canBackward, canForward bool
	var currentCommit string

	if isRepo {
		canBackward, _ = gitManager.CanMoveBackward()
		canForward, _ = gitManager.CanMoveForward()
		currentCommit, _ = gitManager.GetCurrentCommit()
	}
	fmt.Printf("canBackward: %v\n", canBackward)
	fmt.Printf("canForward: %v\n", canForward)
	fmt.Printf("currentCommit: %v\n", currentCommit)

	resp := GitResponse{
		Success:      true,
		CanBackward:  canBackward,
		CanForward:   canForward,
		CurrentState: currentCommit,
	}
	fmt.Println(resp.CanForward) // Print the response for debugging purposes

	return c.JSON(http.StatusOK, resp)
}
