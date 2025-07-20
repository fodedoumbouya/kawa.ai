package utility

import (
	"bufio"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/fodedoumbouya/kawa.ai/internal/constant"
	directory_utils "github.com/fodedoumbouya/kawa.ai/internal/directory"
)

// Updated helper function to check app usage
func IsAppInUse(host string) bool {
	// Use the fixed health check port 8091
	resp, err := http.Get(host)
	return err == nil && resp.StatusCode == http.StatusOK
}

func DeleteFolder(projectName, projectId string) error {
	rootDir, err := directory_utils.FindRootDir(constant.ServerFolderName)
	if err != nil {
		fmt.Println("Error finding the root directory: ", err)
		return err
	}
	rootDir += "/" + constant.GeneratedProjectDirectory
	projectName = projectName + "_" + projectId
	cmd := exec.Command("rm", "-rf", projectName)
	cmd.Dir = rootDir
	err = cmd.Run()
	if err != nil {
		fmt.Println("Error deleting folder: ", err)
		return err
	}
	return nil

}

func RunDartApp(projectName, projectId string) (string, int, error) {
	projectName = projectName + "_" + projectId
	// Run the command to start the flutter app
	cmd := exec.Command("dart", "run", "launcher.dart", projectName, constant.GeneratedProjectDirectory)
	rootDir, err := directory_utils.FindRootDir(constant.ServerFolderName)
	if err != nil {
		fmt.Println("Error finding the root directory: ", err)
		return "", 0, err
	}

	rootDir += "/pkg/script"
	cmd.Dir = rootDir

	// Create pipes for stdout/stderr
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		fmt.Println("Error creating stdout pipe: ", err)
		return "", 0, err
	}
	cmd.Stderr = cmd.Stdout // Redirect stderr to stdout

	// Start the command
	if err := cmd.Start(); err != nil {
		fmt.Println("Error running the dart app: ", err)
		return "", 0, err
	}

	// Scan output for localhost pattern
	portChan := make(chan string)
	go func() {
		scanner := bufio.NewScanner(stdout)
		for scanner.Scan() {
			line := scanner.Text()
			fmt.Println(line) // Print output for debugging
			if strings.Contains(line, "localhost:") || strings.Contains(line, "0.0.0.0:") {
				// Extract port number
				if port := extractPort(line); port != "" {
					portChan <- port
					return
				}
			}
		}
		portChan <- "" // Signal no port found
	}()

	// Wait for port or timeout
	select {
	case port := <-portChan:
		if port == "" {
			return "", 0, fmt.Errorf("failed to detect port in output")
		}
		pid, _ := ExactPidDart(port)
		return "http://localhost:" + port, pid, nil
	case <-time.After(2 * time.Minute):
		return "", 0, fmt.Errorf("timeout waiting for localhost detection")
	}
}

func ExactPidDart(port string) (int, error) {
	// Use lsof to find the process ID using the port
	cmd := exec.Command("lsof", "-i", fmt.Sprintf(":%s", port))
	output, err := cmd.Output()
	if err != nil {
		return 0, fmt.Errorf("error finding process by port %s: %v", port, err)
	}

	// Parse the output to find the PID
	scanner := bufio.NewScanner(strings.NewReader(string(output)))
	// get the pid where commad is dart
	for scanner.Scan() {
		line := scanner.Text()
		if strings.Contains(line, "dart") {
			fields := strings.Fields(line)
			if len(fields) > 1 {
				pid := fields[1]
				// Convert PID to int
				pidInt, err := strconv.Atoi(pid)
				if err != nil {
					return 0, fmt.Errorf("error converting PID %s to int: %v", pid, err)
				}
				return pidInt, nil
			}
		}
	}
	return 0, fmt.Errorf("no process found listening on port %s", port)

}

// New function to terminate the app
func TerminateApp(pid int) error {
	// This assumes you have a way to terminate the process
	// You might need to store the process reference from RunDartApp
	process, err := os.FindProcess(pid)
	fmt.Println("Terminating app with PID:", pid)
	if err == nil {
		err = process.Kill()
		if err == nil {
			fmt.Println("App terminated successfully")
			return nil
		}
		fmt.Println("Error terminating app:", err)
	}
	return fmt.Errorf("error terminating app with PID %d: %v", pid, err)
}

// Helper function to extract port number
func extractPort(line string) string {
	// Match "localhost:" followed by numbers
	re := regexp.MustCompile(`localhost:(\d+)`)
	matches := re.FindStringSubmatch(line)
	if len(matches) > 1 {
		return matches[1]
	}
	// Match "0.0.0.0:" followed by numbers
	re = regexp.MustCompile(`0\.0\.0\.0:(\d+)`)
	matches = re.FindStringSubmatch(line)
	if len(matches) > 1 {
		return matches[1]
	}
	return ""
}

// create flutter project
func CreateFlutterProject(projectName, projectId string) error {
	projectName = projectName + "_" + projectId
	rootDir, err := directory_utils.FindRootDir(constant.ServerFolderName)
	if err != nil {
		fmt.Println("Error finding the root directory: ", err)
		return err
	}
	rootDir += "/" + constant.GeneratedProjectDirectory
	cmd := exec.Command("flutter", "create", projectName)
	cmd.Dir = rootDir
	err = cmd.Run()
	if err != nil {
		fmt.Println("Error creating flutter project: ", err)
		return err
	}
	return nil
}

func CleanJSONResponse(input string) string {
	// First, handle common JSON formatting issues
	cleaned := input

	// Fix escaped single quotes that are causing the error
	cleaned = strings.ReplaceAll(cleaned, `\'`, "'")

	// Handle backslash escapes properly
	cleaned = strings.ReplaceAll(cleaned, `\\`, "\\")

	// Fix common JSON structural issues
	cleaned = strings.ReplaceAll(cleaned, ",\n}", "\n}")
	cleaned = strings.ReplaceAll(cleaned, ",\n  }", "\n  }")
	cleaned = strings.ReplaceAll(cleaned, ",\n\t}", "\n\t}")
	cleaned = strings.ReplaceAll(cleaned, ",}", "}")

	// Handle potential control characters
	cleaned = strings.ReplaceAll(cleaned, "\t", "    ")

	// Specifically look for problematic escape sequences in string literals
	// This regex finds string literals and processes them
	re := regexp.MustCompile(`"([^"\\]*(\\.[^"\\]*)*)"`)
	cleaned = re.ReplaceAllStringFunc(cleaned, func(match string) string {
		// Remove the quotes to process just the content
		content := match[1 : len(match)-1]

		// Fix any invalid escape sequences
		content = strings.ReplaceAll(content, `\'`, "'")  // Replace \' with just '
		content = strings.ReplaceAll(content, `\"`, `\"`) // Ensure \" is properly escaped
		content = strings.ReplaceAll(content, `\$`, "$")  // Handle invalid $ escape sequence
		content = strings.ReplaceAll(content, `\.`, ".")  // Handle invalid . escape sequence

		// Restore the quotes
		return `"` + content + `"`
	})

	return cleaned
}

func AggressiveJSONClean(input string) string {
	// This function handles more complex cases when standard cleaning fails

	// Try to fix any remaining invalid escape sequences
	const (
		inString = iota
		inEscape
		normal
	)

	var result strings.Builder
	state := normal

	for i := 0; i < len(input); i++ {
		ch := input[i]

		switch state {
		case normal:
			if ch == '"' {
				state = inString
			}
			result.WriteByte(ch)

		case inString:
			if ch == '\\' {
				state = inEscape
				result.WriteByte(ch)
			} else if ch == '"' {
				state = normal
				result.WriteByte(ch)
			} else {
				result.WriteByte(ch)
			}

		case inEscape:
			// Only allow valid escape characters
			validEscapes := "\"\\bfnrt/"
			if strings.ContainsRune(validEscapes, rune(ch)) {
				result.WriteByte(ch)
			} else if ch == '\'' {
				// Convert \' to just '
				result.WriteByte('\'')
			} else {
				// For any other invalid escape, just add the character without the escape
				result.WriteByte(ch)
			}
			state = inString
		}
	}

	return result.String()
}
