package config

import (
	llm "github.com/fodedoumbouya/kawa.ai/internal/llm"
)

type APISettingReponse struct {
	ModelHost string   `json:"model_host"`
	ModelList []string `json:"model_list"`
}

type APISetting struct {
	ModelHost llm.LlmType `json:"model_host"`
	ModelList []string    `json:"model_list"`
}

// list of APISetting
var supportApiSetting = []APISetting{
	// {
	// 	ModelHost: llm.Gemini,
	// 	ModelList: []string{llm.Gemini20FlashExp},
	// },
	{
		ModelHost: llm.Gemini,
		ModelList: []string{llm.Gemini20FlashExp, llm.Gemini25Flash},
	},
	{
		ModelHost: llm.Mistral,
		ModelList: []string{llm.MistralLarge},
	},
}

func GetSupportAPISetting() []APISettingReponse {
	var supportApiSettingReponse []APISettingReponse
	for _, setting := range supportApiSetting {
		modelHosh := ""
		switch setting.ModelHost {
		case llm.Gemini:
			modelHosh = "Gemini"
		case llm.Mistral:
			modelHosh = "Mistral"
		}
		if modelHosh != "" {
			supportApiSettingReponse = append(supportApiSettingReponse, APISettingReponse{
				ModelHost: modelHosh,
				ModelList: setting.ModelList,
			})

		}
	}
	return supportApiSettingReponse
}
