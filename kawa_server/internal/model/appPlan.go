package model

type UserRequirements struct {
	FrontEnd struct {
		Screens []string `json:"screen"`
	} `json:"frontEnd"`
	BackEnd struct {
		APIs []string `json:"api"`
	} `json:"backEnd"`
}

type NextAgentPlan struct {
	ModelStructure map[string]map[string]interface{} `json:"model-structure"`
	FrontEnd       struct {
		DesignReference string                         `json:"designReference"`
		Screens         []map[string]string            `json:"screen"`
		DeviceCache     []map[string]map[string]string `json:"device-cache"`
	} `json:"frontEnd"`
	BackEnd struct {
		DesignReference string        `json:"designReference"`
		APICalls        []APICallPlan `json:"api-call"`
	} `json:"backEnd"`
}
type APICallPlan struct {
	Method string      `json:"method"`
	Path   string      `json:"path"`
	Data   RequestData `json:"data"`
}

type RequestData struct {
	Request  []map[string]interface{} `json:"request"`
	Response []map[string]interface{} `json:"response"`
}

type AppPlan struct {
	AppName   string           `json:"appName"`
	User      UserRequirements `json:"user"`
	NextAgent NextAgentPlan    `json:"nextAgent"`
	Questions []string         `json:"questions"`
	Message   string           `json:"message"`
}
