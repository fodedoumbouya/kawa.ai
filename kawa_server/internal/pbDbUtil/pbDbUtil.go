package pbdbutil

import (
	"errors"

	"github.com/pocketbase/pocketbase/core"
)

func GetProjectPlanData(c *core.RequestEvent) (core.Record, error) {
	projectId := c.Request.PathValue("projectId")
	if projectId == "" {
		return core.Record{}, errors.New("projectId is required")
	}

	projectData, err := GetProjectData(projectId, c)
	if err != nil {
		return core.Record{}, err
	}

	return projectData, nil
}

func TestRecord(c *core.RequestEvent) error {
	collection, err := c.App.FindCollectionByNameOrId("projects")
	if err != nil {
		return err
	}
	record := core.NewRecord(collection)

	record.Set("projectName", "Test Project")
	record.Set("projectStructure", "c *core.RequestEvent")
	record.Set("routers", "")

	err = c.App.Save(record)
	if err != nil {
		return err
	}
	return nil
}

func GetUserFromToken(c *core.RequestEvent) (core.Record, error) {
	token := c.Request.Header.Get("Authorization")
	token = token[7:]
	record, err := c.App.FindAuthRecordByToken(token)
	if err != nil {
		return core.Record{}, err
	}
	return *record, nil

}

func GetProjectData(id string, c *core.RequestEvent) (core.Record, error) {
	record, err := c.App.FindRecordById("projects", id)
	if err != nil {
		return core.Record{}, err
	}
	return *record, nil

}
