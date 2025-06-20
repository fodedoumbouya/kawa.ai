package model

type AppNavigationModel struct {
	AppNavigation struct {
		EntryPoint struct {
			Screen               string      `json:"screen"`
			DestinationOnSuccess interface{} `json:"destinationOnSuccess"`
		} `json:"entryPoint"`
		BottomTabNavigation struct {
			Screens  []string `json:"screens"`
			Behavior string   `json:"behavior"`
		} `json:"bottomTabNavigation"`
		ContentScreens struct {
			AccessibleFrom []string `json:"accessibleFrom"`
			Screens        []string `json:"screens"`
		} `json:"contentScreens"`
		NavigationRules struct {
			HierarchyLevels struct {
				Level1  []string      `json:"level1"`
				Level2  []string      `json:"level2"`
				Level3  []interface{} `json:"level3"`
				Level4  []interface{} `json:"level4"`
				Utility []interface{} `json:"utility"`
			} `json:"hierarchyLevels"`
			Transitions struct {
				AllowBackNavigation  bool `json:"allowBackNavigation"`
				MaintainTabSelection bool `json:"maintainTabSelection"`
			} `json:"transitions"`
		} `json:"navigationRules"`
		Path map[string]string `json:"path"`
	} `json:"appNavigation"`
}
