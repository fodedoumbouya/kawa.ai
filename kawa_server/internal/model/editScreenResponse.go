package model

type EditScreenChat struct {
	ProjectId      string `json:"projectId"`
	CurrentScreen  string `json:"currentScreen"`
	AgentQuestion  string `json:"agentQuestion"`
	UserPrompt     string `json:"userPrompt"`
	AgentResponse  string `json:"agentResponse"`
	ProgressStatus string `json:"progressStatus"`
}

type EditScreenResponse struct {
	User struct {
		Question    string `json:"question"`
		UserMessage string `json:"userMessage"`
	} `json:"user"`
	NextAgent struct {
		Prompt            string   `json:"prompt"`
		CurrentViewScreen string   `json:"currentViewScreen"`
		ReferenceFiles    []string `json:"referenceFiles"`
		NewScreen         []string `json:"newScreen"`
		NewPackage        []string `json:"newPackage"`
	} `json:"nextAgent"`
}
