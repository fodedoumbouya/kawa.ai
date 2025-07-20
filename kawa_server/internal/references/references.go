package references

import (
	"encoding/json"
	"fmt"
	"slices"

	"github.com/pocketbase/pocketbase/core"
)

// TODO: incoming features for the frontend

type Reference struct {
	Key   string `json:"key"`
	Value string `json:"value"`
}
type ScreenReference struct {
	ScreenName string      `json:"screenName"`
	ScreenData []Reference `json:"screenData"`
}
type References struct {
	Global  []Reference       `json:"global"`
	Screens []ScreenReference `json:"screens"`
}

func GetReferrences(c *core.RequestEvent) (References, error) {
	ref, err := getReferenceData(c)
	if err != nil {
		return References{}, err
	}
	return ref, nil
}

func GetGlobalReferrences(c *core.RequestEvent) ([]Reference, error) {
	ref, err := getReferenceData(c)
	if err != nil {
		return nil, err
	}
	return ref.Global, nil
}

func GetScreenReferrences(c *core.RequestEvent) ([]ScreenReference, error) {
	ref, err := getReferenceData(c)
	if err != nil {
		return nil, err
	}
	return ref.Screens, nil
}
func GetScreenReferrencesByName(c *core.RequestEvent, screenName string) ([]Reference, error) {
	ref, err := getReferenceData(c)
	if err != nil {
		return nil, err
	}
	for _, screen := range ref.Screens {
		if screen.ScreenName == screenName {
			return screen.ScreenData, nil
		}
	}
	return nil, nil
}
func GetScreenReferenceByKey(c *core.RequestEvent, key string) (string, error) {

	ref, err := getReferenceData(c)
	if err != nil {
		return "", err
	}
	for _, screen := range ref.Screens {
		for _, ref := range screen.ScreenData {
			if ref.Key == key {
				return ref.Value, nil
			}
		}
	}
	return "", nil
}

func getReferenceData(c *core.RequestEvent) (References, error) {
	projectId := c.Request.PathValue("projectId")
	if projectId == "" {
		return References{}, fmt.Errorf("projectId is required")
	}
	// Get the project
	refs, err := c.App.FindRecordById("references", projectId)
	if err != nil {
		return References{}, err
	}

	// Get the global references
	rawRef := refs.GetString("reference")
	// Unmarshal the references
	var references References
	err = json.Unmarshal([]byte(rawRef), &references)
	if err != nil {
		return References{}, err
	}
	return references, nil
}

// add a reference to a screen
func AddReferenceToScreen(c *core.RequestEvent, screenName string, key string, value string) error {
	projectId := c.Request.PathValue("projectId")
	if projectId == "" {
		return fmt.Errorf("projectId is required")
	}
	ref, err := getReferenceData(c)
	if err != nil {
		return err
	}
	// Check if the screen exists
	var screenVerif ScreenReference
	for _, screen := range ref.Screens {
		if screen.ScreenName == screenName {
			screenVerif = screen
			break
		}
	}
	if screenVerif.ScreenName == "" {
		return fmt.Errorf("screen does not exist")
	}
	// Check if the key exists
	for _, ref := range screenVerif.ScreenData {
		if ref.Key == key {
			return fmt.Errorf("key already exists")
		}
	}
	// Add the reference
	ref.Screens = append(ref.Screens, ScreenReference{ScreenName: screenName, ScreenData: []Reference{{Key: key, Value: value}}})
	// Marshal the references
	rawRef, err := json.Marshal(ref)
	if err != nil {
		return err
	}

	refsDB, err := c.App.FindRecordById("references", projectId)
	if err != nil {
		return err
	}
	// Save the references
	refsDB.Set("reference", string(rawRef))
	err = c.App.Save(refsDB)
	if err != nil {
		return err
	}
	return nil

}

// update a screen reference
func UpdateScreenReference(c *core.RequestEvent, screenName string, key string, value string) error {
	projectId := c.Request.PathValue("projectId")
	if projectId == "" {
		return fmt.Errorf("projectId is required")
	}
	ref, err := getReferenceData(c)
	if err != nil {
		return err
	}
	// Check if the screen exists
	var screenVerif ScreenReference
	for _, screen := range ref.Screens {
		if screen.ScreenName == screenName {

			screenVerif = screen
			break
		}
	}
	if screenVerif.ScreenName == "" {
		return fmt.Errorf("screen does not exist")
	}
	// Check if the key exists
	var refVerif Reference
	for _, ref := range screenVerif.ScreenData {
		if ref.Key == key {
			refVerif = ref
			break
		}
	}
	if refVerif.Key == "" {
		return fmt.Errorf("key does not exist")
	}
	// Update the reference
	refVerif.Value = value
	// remove refVerif from screenVerif
	for i, ref := range screenVerif.ScreenData {
		if ref.Key == key {
			screenVerif.ScreenData = slices.Delete(screenVerif.ScreenData, i, i+1)
			screenVerif.ScreenData = append(screenVerif.ScreenData, refVerif)
			break
		}
	}

	// remove screenVerif from ref
	for i, screen := range ref.Screens {
		if screen.ScreenName == screenName {
			ref.Screens = slices.Delete(ref.Screens, i, i+1)
			ref.Screens = append(ref.Screens, screenVerif)
			break
		}
	}

	// Marshal the references
	rawRef, err := json.Marshal(ref)
	if err != nil {
		return err
	}
	refsDB, err := c.App.FindRecordById("references", projectId)
	if err != nil {
		return err
	}
	// Save the references
	refsDB.Set("reference", string(rawRef))
	err = c.App.Save(refsDB)
	if err != nil {
		return err
	}
	return nil
}
