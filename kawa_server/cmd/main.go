package main

import (
	"log"

	"github.com/fodedoumbouya/kawa.ai/api/handler"
	reload "github.com/fodedoumbouya/kawa.ai/internal/hotRestartChannel"
	projectProgess "github.com/fodedoumbouya/kawa.ai/internal/projectProgressState"
	createcollections "github.com/fodedoumbouya/kawa.ai/pkg/createCollections"

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

}

func main() {
	app := pocketbase.New()
	// init websocket for creating moment and refresh debug on the webUI
	reload.InitHotReload()
	projectProgess.InitProjectProgress()

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// Create collections on first serve
		requestEvent := &core.RequestEvent{
			App: se.App,
		}

		// Create all collections if they don't exist
		if err := createcollections.CreateAllCollections(requestEvent); err != nil {
			log.Fatalf("Error creating collections: %v", err)

		}

		handler.Handler(se)

		return se.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
