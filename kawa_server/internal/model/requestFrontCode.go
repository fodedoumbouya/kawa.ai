package model

type RequestFrontCode struct {
	Structure      DirEntryStructure            `json:"structure"`
	Packages       []string                     `json:"packages"`
	Screens        []string                     `json:"screens"`
	APICall        APICall                      `json:"api-call"`
	ModelStructure map[string]map[string]string `json:"model-structure"`
	Progress       Progress                     `json:"progress"`
}

type APICall struct {
	Post map[string]map[string]interface{} `json:"POST"`
	Get  map[string]map[string]interface{} `json:"GET"`
}

type Progress struct {
	DesignReference              string        `json:"designReference"`
	Allscreen                    []string      `json:"Allscreen"`
	CurrentScreen                string        `json:"currentScreen"`
	CurrentScreenDetailReference string        `json:"currentScreenDetailReference"`
	BuildScreen                  []interface{} `json:"buildScreen"`
}
