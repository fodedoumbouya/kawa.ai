package config

import (
	config "github.com/fodedoumbouya/kawa.ai/internal/config"

	"github.com/pocketbase/pocketbase/core"
)

func SendSupportAPISetting(c *core.RequestEvent) error {

	supportApiSetting := config.GetSupportAPISetting()

	return c.JSON(200, supportApiSetting)

}
