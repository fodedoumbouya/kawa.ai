package llm

/// add mistral llm call here
import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/fodedoumbouya/kawa.ai/internal/constant"
	"github.com/fodedoumbouya/kawa.ai/internal/utility"
)

// Define the structure of the request body
type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type RequestBody struct {
	Model          string    `json:"model"`
	Messages       []Message `json:"messages"`
	ResponseFormat struct {
		Type string `json:"type"`
	} `json:"response_format"`
}

func RequestMistral(arguments RequestLLMArguments) (string, error) {
	// Define the API endpoint and the API key
	url := constant.MistralDefaultHostUrl
	apiKey := arguments.APIKey
	/// read the instruction from the markdown file
	instructionProject, _ := utility.ReadSingleMarkdownFile(arguments.Instruction)

	/// if the model name is not provided, use the default model name
	modelName := arguments.ModelName
	if modelName == "" {
		modelName = CodestralLatest
	}

	// Create the request body
	requestBody := RequestBody{
		Model: modelName,
		Messages: []Message{
			{
				Role:    "user",
				Content: instructionProject,
			},
			{
				Role:    "assistant",
				Content: `{"status": "ok"}`,
			},
			{
				Role:    "user",
				Content: arguments.Prompt,
			},
		},
		ResponseFormat: struct {
			Type string `json:"type"`
		}{Type: "json_object"},
	}
	// Convert the request body to JSON
	jsonData, err := json.Marshal(requestBody)
	if err != nil {
		fmt.Println("Error marshaling JSON:", err)
		return "", err
	}

	// Create a new HTTP request
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Println("Error creating request:", err)
		return "", err
	}

	// Set the headers
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("Authorization", "Bearer "+apiKey)

	// Create an HTTP client and send the request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error sending request:", err)
		return "", err
	}
	defer resp.Body.Close()

	// Check the response status code
	if resp.StatusCode != http.StatusOK {
		fmt.Println("Error: received status code", resp.StatusCode)
		return "", fmt.Errorf("received status code %d", resp.StatusCode)
	}

	// Read and print the response body
	var responseBody map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&responseBody); err != nil {
		fmt.Println("Error decoding response:", err)
		return "", err
	}
	// Response: map[choices:[map[finish_reason:stop index:0 message:map[content:{
	/// get content from the response body
	choices, ok := responseBody["choices"].([]interface{})
	if !ok || len(choices) == 0 {
		return "", fmt.Errorf("invalid response format")
	}
	message, ok := choices[0].(map[string]interface{})["message"].(map[string]interface{})
	if !ok {
		return "", fmt.Errorf("invalid response format")
	}
	content, ok := message["content"].(string)
	if !ok {
		return "", fmt.Errorf("invalid response format")
	}
	return content, nil
}
