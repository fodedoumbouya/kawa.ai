package main

import (
	"log"

	"github.com/fodedoumbouya/kawa.ai/api/handler"
	reload "github.com/fodedoumbouya/kawa.ai/internal/hotRestartChannel"
	projectProgess "github.com/fodedoumbouya/kawa.ai/internal/projectProgressState"

	"github.com/joho/godotenv"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

func init() {
	// load .env file
	err := godotenv.Load("../.env")
	if err != nil {
		log.Fatalf("Error loading .env file")
	}
	// cache.CacheApp.Init()
	reload.InitHotReload()
	projectProgess.InitProjectProgress()

}

func main() {
	app := pocketbase.New()
	app.OnServe().BindFunc(func(se *core.ServeEvent) error {

		handler.Handler(se)
		return se.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
