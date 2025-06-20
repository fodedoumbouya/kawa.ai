package llm

import "fmt"

type LlmType int

const (
	Gemini LlmType = iota
	Mistral
	None
)

// type LlmInstruction string

const (
	AGENT_1_Product_Manager_No_Backend string = "AGENT_1_(Product Manager)_No_Backend"
	AGENT_1_4_NAVIGATION               string = "AGENT_1_4(NAVIGATION)"
	AGENT_1_5_CREATESTRUCTURE_v2       string = "AGENT_1_5(CREATESTRUCTURE)_v2"
	AGENT_Create_Navigation            string = "AGENT_Create_Navigation"
	AGENT_3_Planning_For_Coder         string = "AGENT_3_Planning_For_Coder"
	AGENT_4_Coding                     string = "AGENT_4_Coding"
)

const (
	GeminiExp1206      string = "gemini-exp-1206"
	Gemini20FlashExp   string = "gemini-2.0-flash-exp" // default
	Gemini20ProExp0205 string = "gemini-2.0-pro-exp-02-05"
	Gemini15Flash      string = "gemini-1.5-flash"
	Gemini20Flash      string = "gemini-2.0-flash"
	Gemini25ProExp0325 string = "gemini-2.5-pro-exp-03-25"
	MistralLarge       string = "mistral-large-latest"
	CodestralLatest    string = "codestral-latest"
	Gemini20FlashLite  string = "gemini-2.0-flash-lite"
)

// make the instruction, prompt as obligatory and modelName as optional
type RequestLLMArguments struct {
	Instruction string
	Prompt      string
	ModelName   string
	APIKey      string
}

func RequestToLLM(arguments RequestLLMArguments, llmType LlmType) (string, error) {
	if llmType == Gemini {
		return RequestGemini(arguments)
	} else if llmType == Mistral {
		return RequestMistral(arguments)
	} else {
		return "", fmt.Errorf("llm type not supported")
	}
}

func RequestPlanManager(llmArg RequestLLMArguments, llmType LlmType) (string, error) {
	if llmType == Gemini {
		return GeminiPlanManager(llmArg)
	} else if llmType == Mistral {
		return RequestMistral(llmArg)
	} else {
		return "", fmt.Errorf("llm type not supported")
	}
}
