package model

const (
	Ignore int = 0
	Create int = 1
	Delete int = 2
	Update int = 3
)

type DirEntryStructure struct {
	Name     string              `json:"name"`
	IsDir    bool                `json:"isDir"`
	Action   int                 `json:"action"`
	Children []DirEntryStructure `json:"children,omitempty"`
}

type File struct {
	FileName string `json:"fileName"`
	FilePath string `json:"filePath"`
	Code     string `json:"code"`
}
