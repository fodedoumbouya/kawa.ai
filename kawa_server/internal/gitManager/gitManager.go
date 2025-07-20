package gitmanager

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/fodedoumbouya/kawa.ai/internal/constant"
	directory_utils "github.com/fodedoumbouya/kawa.ai/internal/directory"
)

type GitManager struct {
	ProjectDir string
}

// NewGitManager creates a new git manager for the specified project directory
func NewGitManager(projectName, projectId string) (*GitManager, error) {
	projectName = projectName + "_" + projectId
	rootDir, err := directory_utils.FindRootDir("kawa_server")
	if err != nil {
		return nil, fmt.Errorf("failed to find root directory: %v", err)
	}
	rootDir += fmt.Sprintf("/%s/%s", constant.GeneratedProjectDirectory, projectName)

	return &GitManager{ProjectDir: rootDir}, nil
}

// InitRepo initializes a git repository in the project directory
func (g *GitManager) InitRepo() error {
	cmd := exec.Command("git", "init")
	cmd.Dir = g.ProjectDir
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("git init failed: %w, output: %s", err, string(output))
	}
	return nil
}

// IsGitRepo checks if the project directory is a git repository
func (g *GitManager) IsGitRepo() bool {
	gitDir := filepath.Join(g.ProjectDir, ".git")
	if _, err := os.Stat(gitDir); os.IsNotExist(err) {
		return false
	}
	return true
}

// StageAll stages all changes in the project directory
func (g *GitManager) StageAll() error {
	cmd := exec.Command("git", "add", ".")
	cmd.Dir = g.ProjectDir
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("git add failed: %w, output: %s", err, string(output))
	}
	return nil
}

// CommitChanges commits staged changes with the given message
// This will also clear any existing stashes as we're creating a new commit point
func (g *GitManager) CommitChanges(message string) error {
	// Check if there are changes to commit
	hasChanges, err := g.HasChanges()
	if err != nil {
		return err
	}
	fmt.Println("Has changes:", hasChanges)
	if !hasChanges {
		return nil // No changes to commit
	}
	err = g.StageAll()
	if err != nil {
		return err
	}

	cmd := exec.Command("git", "commit", "-m", message)
	cmd.Dir = g.ProjectDir
	output, err := cmd.CombinedOutput()
	fmt.Println("Commit output:", string(output)) // Debug prin
	if err != nil {
		return fmt.Errorf("git commit failed: %w, output: %s", err, string(output))
	}
	fmt.Println("Changes committed:", string(output))
	return nil
}

// HasChanges checks if there are any changes to commit
func (g *GitManager) HasChanges() (bool, error) {
	cmd := exec.Command("git", "status", "--porcelain")
	cmd.Dir = g.ProjectDir
	output, err := cmd.CombinedOutput()
	if err != nil {
		return false, fmt.Errorf("git status failed: %w, output: %s", err, string(output))
	}
	fmt.Println("Git status output:", string(output))
	return len(strings.TrimSpace(string(output))) > 0, nil
}

// HasUncommittedChanges checks if there are any uncommitted changes
func (g *GitManager) HasUncommittedChanges() (bool, error) {
	return g.HasChanges()
}

// StashChanges stashes any uncommitted changes with a specific message
func (g *GitManager) StashChanges(message string) error {
	// Check if there are any changes to stash
	hasChanges, err := g.HasUncommittedChanges()
	if err != nil {
		return err
	}
	if !hasChanges {
		return nil // No changes to stash
	}

	cmd := exec.Command("git", "stash", "push", "-m", message)
	cmd.Dir = g.ProjectDir
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("git stash failed: %w, output: %s", err, string(output))
	}
	return nil
}

// HasStashes checks if there are any stashes
func (g *GitManager) HasStashes() (bool, error) {
	cmd := exec.Command("git", "stash", "list")
	cmd.Dir = g.ProjectDir
	output, err := cmd.CombinedOutput()
	if err != nil {
		return false, fmt.Errorf("git stash list failed: %w, output: %s", err, string(output))
	}
	return len(strings.TrimSpace(string(output))) > 0, nil
}

// HasMultipleCommits checks if there are at least two commits in the repository
// This ensures we can safely do HEAD~1
func (g *GitManager) HasMultipleCommits() (bool, error) {
	// Run git rev-list --count HEAD to get the number of commits
	cmd := exec.Command("git", "rev-list", "--count", "HEAD")
	cmd.Dir = g.ProjectDir
	output, err := cmd.CombinedOutput()
	if err != nil {
		return false, nil // Error usually means no commits or invalid HEAD
	}

	// Parse the commit count
	count := strings.TrimSpace(string(output))
	if count == "1" {
		return false, nil // Only one commit
	}

	return true, nil // Multiple commits exist
}

// HasPreviousCommit checks if there's at least one commit in the repository
func (g *GitManager) HasPreviousCommit() (bool, error) {
	cmd := exec.Command("git", "rev-parse", "--verify", "HEAD")
	cmd.Dir = g.ProjectDir
	err := cmd.Run()
	// If the command succeeds, HEAD exists
	return err == nil, nil
}

// UndoLastCommit undoes the last commit but keeps the changes staged
// Uses different approaches based on the number of commits
func (g *GitManager) UndoLastCommit() error {
	// First check if we have multiple commits
	hasMultiple, err := g.HasMultipleCommits()
	if err != nil {
		return err
	}

	if hasMultiple {
		// If we have multiple commits, we can use HEAD~1
		cmd := exec.Command("git", "reset", "--soft", "HEAD~1")
		cmd.Dir = g.ProjectDir
		output, err := cmd.CombinedOutput()
		if err != nil {
			return fmt.Errorf("git reset --soft failed: %w, output: %s", err, string(output))
		}
	} else {
		// For the initial commit, we need a different approach
		// Get the hash of the empty tree
		emptyTree := "4b825dc642cb6eb9a060e54bf8d69288fbee4904" // This is the hash of an empty tree in Git

		// Reset to the empty tree but keep the changes staged
		cmd := exec.Command("git", "reset", "--soft", emptyTree)
		cmd.Dir = g.ProjectDir
		_, err := cmd.CombinedOutput()
		if err != nil {
			// If that fails, try another approach for the initial commit
			// We'll create an orphaned branch and then delete the original branch
			branchName, err := g.GetCurrentBranch()
			if err != nil {
				return fmt.Errorf("failed to get current branch: %w", err)
			}

			// Create an orphaned branch (this effectively resets to nothing)
			tempBranch := "temp_orphan"
			cmd = exec.Command("git", "checkout", "--orphan", tempBranch)
			cmd.Dir = g.ProjectDir
			output, err := cmd.CombinedOutput()
			if err != nil {
				return fmt.Errorf("git checkout --orphan failed: %w, output: %s", err, string(output))
			}

			// Stage all files
			if err = g.StageAll(); err != nil {
				return err
			}

			// Delete the original branch
			cmd = exec.Command("git", "branch", "-D", branchName)
			cmd.Dir = g.ProjectDir
			_, _ = cmd.CombinedOutput() // Ignore errors here

			// Rename the temp branch back to the original
			cmd = exec.Command("git", "branch", "-m", branchName)
			cmd.Dir = g.ProjectDir
			output, err = cmd.CombinedOutput()
			if err != nil {
				return fmt.Errorf("git branch -m failed: %w, output: %s", err, string(output))
			}
		}
	}

	return nil
}

// GetCurrentBranch returns the name of the current branch
func (g *GitManager) GetCurrentBranch() (string, error) {
	cmd := exec.Command("git", "rev-parse", "--abbrev-ref", "HEAD")
	cmd.Dir = g.ProjectDir
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("git rev-parse --abbrev-ref failed: %w, output: %s", err, string(output))
	}
	return strings.TrimSpace(string(output)), nil
}

// CanMoveBackward checks if there are changes to stash or commits to undo
func (g *GitManager) CanMoveBackward() (bool, error) {
	// First check if there are uncommitted changes
	hasChanges, err := g.HasChanges()
	if err != nil {
		return false, err
	}
	if hasChanges {
		return true, nil
	}

	// If no uncommitted changes, check if there's a previous commit
	return g.HasPreviousCommit()
}

// MoveBackward stashes all current changes with a default message
// If no changes are present, it will undo the last commit and stash those changes
func (g *GitManager) MoveBackward() error {
	// Check if we have changes to stash
	hasChanges, err := g.HasChanges()
	if err != nil {
		return err
	}

	if hasChanges {
		// If we have changes, just stash them
		// Get current commit for reference (if it exists)
		currentCommit, _ := g.GetCurrentCommit()
		commitRef := "initial"
		if currentCommit != "" {
			commitRef = currentCommit[:7]
		}

		stashMessage := fmt.Sprintf("MoveBackward_%s", commitRef)
		if err = g.StashChanges(stashMessage); err != nil {
			return err
		}
		fmt.Println("Changes stashed successfully")
		return nil
	}

	// No changes, check if we can undo a commit
	hasPrevCommit, err := g.HasPreviousCommit()
	if err != nil {
		return err
	}
	if !hasPrevCommit {
		return fmt.Errorf("no changes to stash and no previous commits to undo")
	}

	// Get the commit message of the last commit for reference
	cmd := exec.Command("git", "log", "-1", "--pretty=%B")
	cmd.Dir = g.ProjectDir
	commitMsg, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("failed to get last commit message: %w", err)
	}

	// Get current commit for reference
	currentCommit, err := g.GetCurrentCommit()
	if err != nil {
		return err
	}

	// Undo the last commit but keep the changes staged
	if err := g.UndoLastCommit(); err != nil {
		return err
	}

	// Now stash these changes
	stashMessage := fmt.Sprintf("UndoneCommit_%s_%s", currentCommit[:7], strings.TrimSpace(string(commitMsg)))
	if err := g.StashChanges(stashMessage); err != nil {
		return err
	}

	fmt.Println("Last commit undone and changes stashed successfully")
	return nil
}

// CanMoveForward checks if there are stashes to apply
func (g *GitManager) CanMoveForward() (bool, error) {
	return g.HasStashes()
}

// MoveForward pops the most recent stash
func (g *GitManager) MoveForward() error {
	// Check if we have stashes to pop
	hasStashes, err := g.HasStashes()
	if err != nil {
		return err
	}
	if !hasStashes {
		return fmt.Errorf("no stashes to apply")
	}

	// Pop the latest stash (stash@{0})
	cmd := exec.Command("git", "stash", "pop")
	cmd.Dir = g.ProjectDir
	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("git stash pop failed: %w, output: %s", err, string(output))
	}

	fmt.Println("Stash applied successfully:", string(output))
	return nil
}

// GetCurrentCommit returns the hash of the current commit
func (g *GitManager) GetCurrentCommit() (string, error) {
	cmd := exec.Command("git", "rev-parse", "HEAD")
	cmd.Dir = g.ProjectDir
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", nil // Return empty string instead of error
	}
	return strings.TrimSpace(string(output)), nil
}

// AutoCommit automatically stages and commits changes with a default message
// This will also clear any existing stashes as we're creating a new commit point
func (g *GitManager) AutoCommit(message string) error {
	if !g.IsGitRepo() {
		if err := g.InitRepo(); err != nil {
			return err
		}
	}

	if err := g.StageAll(); err != nil {
		return err
	}

	hasChanges, err := g.HasChanges()
	if err != nil {
		return err
	}

	if hasChanges {
		return g.CommitChanges(message)
	}
	return nil
}
