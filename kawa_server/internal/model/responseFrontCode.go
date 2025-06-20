package model

// DirEntryStructure represents a directory or file structure.

type ResponseFrontCode struct {
	Structure DirEntryStructure `json:"structure"`
	Files     []File            `json:"files"`
	Packages  []string          `json:"packages"`
}

type ResponseAskFont struct {
	Screens []Screen `json:"screens"`
}

type Screen struct {
	FileName string `json:"fileName"`
	Code     string `json:"code"`
}
