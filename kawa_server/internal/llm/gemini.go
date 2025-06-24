package llm

import (
	"context"
	"fmt"
	"strings"

	"github.com/fodedoumbouya/kawa.ai/internal/utility"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

var ctx = context.Background()
var llmModelName = "gemini-2.0-flash-exp" //"gemini-exp-1206" //"gemini-2.0-flash-exp"
// var llmModelName2 = "gemini-2.0-flash-exp"
//  "gemini-2.0-flash-exp"
//  "gemini-1.5-flash"

var chatSessionProductManager *genai.ChatSession

// var modelProductManager *genai.GenerativeModel

// func initGemini() {
// 	var clientPorductManager, err1 = genai.NewClient(ctx, option.WithAPIKey(os.Getenv("GEMINI_API_KEY")))
// 	instructionStructureProject, _ := utility.ReadSingleMarkdownFile("AGENT_1_(Product Manager)_No_Backend")
// 	if err1 != nil {
// 		fmt.Println("Error creating client: ", err1)
// 	} else {
// 		modelProductManager = clientPorductManager.GenerativeModel(llmModelName)
// 		chatSessionProductManager = modelProductManager.StartChat()
// 		saveHistory(chatSessionProductManager, instructionStructureProject, `{"status": "ok"}`)
// 	}
// }

func GeminiPlanManager(llmArg RequestLLMArguments) (string, error) {
	client, err := genai.NewClient(ctx, option.WithAPIKey(llmArg.APIKey))
	if err != nil {
		return "", err
	}
	clientModel := client.GenerativeModel(llmModelName).StartChat()

	instructionPrompt, err := utility.ReadSingleMarkdownFile(llmArg.Instruction)
	if err != nil {
		return "", err
	}

	saveHistory(clientModel, instructionPrompt, `{"status": "ok"}`)

	res, err := clientModel.SendMessage(ctx, genai.Text(llmArg.Prompt))
	if err != nil {
		fmt.Println(err)
		return "", err
	}
	jsonData := fmt.Sprintf("%v", res.Candidates[0].Content.Parts[0])
	// replace ```json with empty string
	jsonData = strings.Replace(jsonData, "```json", "", -1)
	// remove the last 4 characters
	jsonData = strings.Replace(jsonData, "```", "", -1)
	return jsonData, nil
}

func RequestGemini(arguments RequestLLMArguments) (string, error) {
	var chat *genai.ChatSession
	llm, err2 := genai.NewClient(ctx, option.WithAPIKey(arguments.APIKey))
	if err2 != nil {
		return "", err2
	}
	/// if the model name is not provided, use the default model name
	modelName := arguments.ModelName
	if modelName == "" {
		return "", fmt.Errorf("modelName is required")
	}
	/// start the chat session
	model := llm.GenerativeModel(modelName)
	model.SetTemperature(0)
	model.SetTopP(0.95)

	chat = model.StartChat()

	fmt.Println("modelName: ", modelName)
	/// read the instruction from the markdown file
	instructionProject, _ := utility.ReadSingleMarkdownFile(arguments.Instruction)
	/// save the history
	chat.History = []*genai.Content{
		{
			Parts: []genai.Part{
				genai.Text(instructionProject),
			},
			Role: "user",
		},
		{
			Parts: []genai.Part{
				genai.Text(`{"status": "ok"}`),
			},
			Role: "model",
		},
	}
	/// send the message
	res, err := chat.SendMessage(ctx, genai.Text(arguments.Prompt))
	if err != nil {
		fmt.Println("Error sending message: ", err)
		return "", err
	}
	/// get the response and return the json data
	jsonData := fmt.Sprintf("%v", res.Candidates[0].Content.Parts[0])
	jsonData = jsonData[7 : len(jsonData)-4]
	return jsonData, nil

}

func saveHistory(cs *genai.ChatSession, userContent string, modelContent string) {
	cs.History = []*genai.Content{
		{
			Parts: []genai.Part{
				genai.Text(userContent),
			},
			Role: "user",
		},
		{
			Parts: []genai.Part{
				genai.Text(modelContent),
			},
			Role: "model",
		},
	}
}
