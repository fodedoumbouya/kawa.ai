package config

import (
	llm "go_manager/internal/llm"
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
	{
		ModelHost: llm.Gemini,
		ModelList: []string{llm.Gemini20FlashExp},
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
		if setting.ModelHost == llm.Gemini {
			modelHosh = "Gemini"
		} else if setting.ModelHost == llm.Mistral {
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
