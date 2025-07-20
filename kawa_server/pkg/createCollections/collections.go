package createcollections

import (
	"github.com/pocketbase/pocketbase/core"
	"github.com/pocketbase/pocketbase/tools/types"
)

func CreateUsersCollection(c *core.RequestEvent) error {
	// Check if collection already exists
	existingCollection, err := c.App.FindCollectionByNameOrId("users")
	if err == nil && existingCollection != nil {
		// Collection exists, check and add missing fields
		return updateUsersCollectionFields(c.App, existingCollection)
	}

	// Create new auth collection for users
	collection := core.NewAuthCollection("users")
	collection.Name = "users"

	// Set authentication rules
	collection.ListRule = types.Pointer("id = @request.auth.id")
	collection.ViewRule = types.Pointer("id = @request.auth.id")
	collection.CreateRule = types.Pointer("")
	collection.UpdateRule = types.Pointer("id = @request.auth.id")
	collection.DeleteRule = types.Pointer("id = @request.auth.id")

	// Add custom fields based on the schema
	// Name field
	collection.Fields.Add(&core.TextField{
		Name:     "name",
		Required: false,
		Max:      255,
		Min:      0,
	})

	// Avatar field for profile pictures
	collection.Fields.Add(&core.FileField{
		Name:      "avatar",
		Required:  false,
		MaxSelect: 1,
		MaxSize:   0, // 0 means no limit
		MimeTypes: []string{
			"image/jpeg",
			"image/png",
			"image/svg+xml",
			"image/gif",
			"image/webp",
		},
		Protected: false,
	})

	// Created timestamp
	collection.Fields.Add(&core.AutodateField{
		Name:     "created",
		OnCreate: true,
		OnUpdate: false,
	})

	// Updated timestamp
	collection.Fields.Add(&core.AutodateField{
		Name:     "updated",
		OnCreate: true,
		OnUpdate: true,
	})

	// Configure auth settings
	collection.AuthAlert.Enabled = true
	collection.AuthAlert.EmailTemplate.Subject = "Login from a new location"
	collection.AuthAlert.EmailTemplate.Body = "<p>Hello,</p>\n<p>We noticed a login to your {APP_NAME} account from a new location.</p>\n<p>If this was you, you may disregard this email.</p>\n<p><strong>If this wasn't you, you should immediately change your {APP_NAME} account password to revoke access from all other locations.</strong></p>\n<p>\n  Thanks,<br/>\n  {APP_NAME} team\n</p>"

	// Configure OAuth2 settings
	collection.OAuth2.Enabled = false
	collection.OAuth2.MappedFields.Name = "name"
	collection.OAuth2.MappedFields.AvatarURL = "avatar"

	// Configure password authentication
	collection.PasswordAuth.Enabled = true
	collection.PasswordAuth.IdentityFields = []string{"email"}

	// Configure MFA
	collection.MFA.Enabled = false
	collection.MFA.Duration = 1800

	// Configure OTP
	collection.OTP.Enabled = false
	collection.OTP.Duration = 180
	collection.OTP.Length = 8
	collection.OTP.EmailTemplate.Subject = "OTP for {APP_NAME}"
	collection.OTP.EmailTemplate.Body = "<p>Hello,</p>\n<p>Your one-time password is: <strong>{OTP}</strong></p>\n<p><i>If you didn't ask for the one-time password, you can ignore this email.</i></p>\n<p>\n  Thanks,<br/>\n  {APP_NAME} team\n</p>"

	// Configure token durations
	collection.AuthToken.Duration = 604800         // 7 days
	collection.PasswordResetToken.Duration = 1800  // 30 minutes
	collection.EmailChangeToken.Duration = 1800    // 30 minutes
	collection.VerificationToken.Duration = 259200 // 3 days
	collection.FileToken.Duration = 180            // 3 minutes

	// Configure email templates
	collection.VerificationTemplate.Subject = "Verify your {APP_NAME} email"
	collection.VerificationTemplate.Body = "<p>Hello,</p>\n<p>Thank you for joining us at {APP_NAME}.</p>\n<p>Click on the button below to verify your email address.</p>\n<p>\n  <a class=\"btn\" href=\"{APP_URL}/_/#/auth/confirm-verification/{TOKEN}\" target=\"_blank\" rel=\"noopener\">Verify</a>\n</p>\n<p>\n  Thanks,<br/>\n  {APP_NAME} team\n</p>"

	collection.ResetPasswordTemplate.Subject = "Reset your {APP_NAME} password"
	collection.ResetPasswordTemplate.Body = "<p>Hello,</p>\n<p>Click on the button below to reset your password.</p>\n<p>\n  <a class=\"btn\" href=\"{APP_URL}/_/#/auth/confirm-password-reset/{TOKEN}\" target=\"_blank\" rel=\"noopener\">Reset password</a>\n</p>\n<p><i>If you didn't ask to reset your password, you can ignore this email.</i></p>\n<p>\n  Thanks,<br/>\n  {APP_NAME} team\n</p>"

	collection.ConfirmEmailChangeTemplate.Subject = "Confirm your {APP_NAME} new email address"
	collection.ConfirmEmailChangeTemplate.Body = "<p>Hello,</p>\n<p>Click on the button below to confirm your new email address.</p>\n<p>\n  <a class=\"btn\" href=\"{APP_URL}/_/#/auth/confirm-email-change/{TOKEN}\" target=\"_blank\" rel=\"noopener\">Confirm new email</a>\n</p>\n<p><i>If you didn't ask to change your email address, you can ignore this email.</i></p>\n<p>\n  Thanks,<br/>\n  {APP_NAME} team\n</p>"

	// Add indexes as defined in the schema
	collection.AddIndex("idx_tokenKey__pb_users_auth_", true, "tokenKey", "")
	collection.AddIndex("idx_email__pb_users_auth_", true, "email", "WHERE `email` != ''")

	// Validate and save the collection
	err = c.App.Save(collection)
	if err != nil {
		return err
	}

	return nil
}

// CreateChatCollection creates the chat collection if it doesn't exist
func CreateChatCollection(c *core.RequestEvent) error {
	// Check if collection already exists
	existingCollection, err := c.App.FindCollectionByNameOrId("chat")
	if err == nil && existingCollection != nil {
		// Collection exists, check and add missing fields
		return updateChatCollectionFields(c.App, existingCollection)
	}

	// Create new chat collection
	collection := core.NewBaseCollection("chat")
	collection.Name = "chat"

	// Set access rules (open access as per schema)
	collection.ListRule = types.Pointer("")
	collection.ViewRule = types.Pointer("")
	collection.CreateRule = nil
	collection.UpdateRule = nil
	collection.DeleteRule = nil

	// Add title field
	collection.Fields.Add(&core.TextField{
		Name:     "title",
		Required: false,
		Max:      0, // 0 means no limit
		Min:      0,
	})

	// Add project relation field (will be set after projects collection is created)
	collection.Fields.Add(&core.RelationField{
		Name:          "project",
		Required:      false,
		MaxSelect:     1,
		MinSelect:     0,
		CascadeDelete: false,
		CollectionId:  "pbc_3853224427", // projects collection ID from schema
	})

	// Add timestamps
	collection.Fields.Add(&core.AutodateField{
		Name:     "created",
		OnCreate: true,
		OnUpdate: false,
	})

	collection.Fields.Add(&core.AutodateField{
		Name:     "updated",
		OnCreate: true,
		OnUpdate: true,
	})

	// Save collection
	err = c.App.Save(collection)
	if err != nil {
		return err
	}

	return nil
}

// CreateMessageCollection creates the message collection if it doesn't exist
func CreateMessageCollection(c *core.RequestEvent) error {
	// Check if collection already exists
	existingCollection, err := c.App.FindCollectionByNameOrId("message")
	if err == nil && existingCollection != nil {
		// Collection exists, check and add missing fields
		return updateMessageCollectionFields(c.App, existingCollection)
	}

	// Create new message collection
	collection := core.NewBaseCollection("message")
	collection.Name = "message"

	// Set access rules (open access as per schema)
	collection.ListRule = types.Pointer("")
	collection.ViewRule = types.Pointer("")
	collection.CreateRule = nil
	collection.UpdateRule = nil
	collection.DeleteRule = nil

	// Add role field
	collection.Fields.Add(&core.TextField{
		Name:     "role",
		Required: false,
		Max:      0,
		Min:      0,
	})

	// Add content field
	collection.Fields.Add(&core.TextField{
		Name:     "content",
		Required: false,
		Max:      0,
		Min:      0,
	})

	// Add chat relation field
	collection.Fields.Add(&core.RelationField{
		Name:          "chat",
		Required:      false,
		MaxSelect:     1,
		MinSelect:     0,
		CascadeDelete: false,
		CollectionId:  "pbc_3802282532", // chat collection ID from schema
	})

	// Add timestamps
	collection.Fields.Add(&core.AutodateField{
		Name:     "created",
		OnCreate: true,
		OnUpdate: false,
	})

	collection.Fields.Add(&core.AutodateField{
		Name:     "updated",
		OnCreate: true,
		OnUpdate: true,
	})

	// Save collection
	err = c.App.Save(collection)
	if err != nil {
		return err
	}

	return nil
}

// CreateProjectAddressCollection creates the project_address collection if it doesn't exist
func CreateProjectAddressCollection(c *core.RequestEvent) error {
	// Check if collection already exists
	existingCollection, err := c.App.FindCollectionByNameOrId("project_address")
	if err == nil && existingCollection != nil {
		// Collection exists, check and add missing fields
		return updateProjectAddressCollectionFields(c.App, existingCollection)
	}

	// Create new project_address collection
	collection := core.NewBaseCollection("project_address")
	collection.Name = "project_address"

	// Set access rules (open access as per schema)
	collection.ListRule = types.Pointer("")
	collection.ViewRule = types.Pointer("")
	collection.CreateRule = nil
	collection.UpdateRule = nil
	collection.DeleteRule = nil

	// Add project relation field
	collection.Fields.Add(&core.RelationField{
		Name:          "project",
		Required:      false,
		MaxSelect:     1,
		MinSelect:     0,
		CascadeDelete: false,
		CollectionId:  "pbc_3853224427", // projects collection ID from schema
	})

	// Add URL field
	collection.Fields.Add(&core.URLField{
		Name:          "url",
		Required:      false,
		ExceptDomains: nil,
		OnlyDomains:   nil,
	})

	// Add PID field
	collection.Fields.Add(&core.TextField{
		Name:     "pid",
		Required: false,
		Max:      0,
		Min:      0,
	})

	// Add timestamps
	collection.Fields.Add(&core.AutodateField{
		Name:     "created",
		OnCreate: true,
		OnUpdate: false,
	})

	collection.Fields.Add(&core.AutodateField{
		Name:     "updated",
		OnCreate: true,
		OnUpdate: true,
	})

	// Save collection
	err = c.App.Save(collection)
	if err != nil {
		return err
	}

	return nil
}

// CreateProjectsCollection creates the projects collection if it doesn't exist
func CreateProjectsCollection(c *core.RequestEvent) error {
	// Check if collection already exists
	existingCollection, err := c.App.FindCollectionByNameOrId("projects")
	if err == nil && existingCollection != nil {
		// Collection exists, check and add missing fields
		return updateProjectsCollectionFields(c.App, existingCollection)
	}

	// Create new projects collection
	collection := core.NewBaseCollection("projects")
	collection.Name = "projects"

	// Set access rules (open access as per schema)
	collection.ListRule = types.Pointer("")
	collection.ViewRule = types.Pointer("")
	collection.CreateRule = nil
	collection.UpdateRule = nil
	collection.DeleteRule = nil

	// Add projectName field
	collection.Fields.Add(&core.TextField{
		Name:     "projectName",
		Required: false,
		Max:      0,
		Min:      0,
	})

	// Add projectStructure JSON field
	collection.Fields.Add(&core.JSONField{
		Name:     "projectStructure",
		Required: false,
		MaxSize:  0,
	})

	// Add routers JSON field
	collection.Fields.Add(&core.JSONField{
		Name:     "routers",
		Required: false,
		MaxSize:  0,
	})

	// Add user relation field
	collection.Fields.Add(&core.RelationField{
		Name:          "user",
		Required:      false,
		MaxSelect:     1,
		MinSelect:     0,
		CascadeDelete: false,
		CollectionId:  "_pb_users_auth_", // users collection ID
	})

	// Add timestamps
	collection.Fields.Add(&core.AutodateField{
		Name:     "created",
		OnCreate: true,
		OnUpdate: false,
	})

	collection.Fields.Add(&core.AutodateField{
		Name:     "updated",
		OnCreate: true,
		OnUpdate: true,
	})

	// Save collection
	err = c.App.Save(collection)
	if err != nil {
		return err
	}

	return nil
}

// CreateReferencesCollection creates the references collection if it doesn't exist
func CreateReferencesCollection(c *core.RequestEvent) error {
	// Check if collection already exists
	existingCollection, err := c.App.FindCollectionByNameOrId("references")
	if err == nil && existingCollection != nil {
		// Collection exists, check and add missing fields
		return updateReferencesCollectionFields(c.App, existingCollection)
	}

	// Create new references collection
	collection := core.NewBaseCollection("references")
	collection.Name = "references"

	// Set access rules (no rules as per schema)
	collection.ListRule = nil
	collection.ViewRule = nil
	collection.CreateRule = nil
	collection.UpdateRule = nil
	collection.DeleteRule = nil

	// Add project relation field
	collection.Fields.Add(&core.RelationField{
		Name:          "project",
		Required:      false,
		MaxSelect:     1,
		MinSelect:     0,
		CascadeDelete: false,
		CollectionId:  "pbc_3853224427", // projects collection ID from schema
	})

	// Add reference JSON field
	collection.Fields.Add(&core.JSONField{
		Name:     "reference",
		Required: false,
		MaxSize:  0,
	})

	// Add timestamps
	collection.Fields.Add(&core.AutodateField{
		Name:     "created",
		OnCreate: true,
		OnUpdate: false,
	})

	collection.Fields.Add(&core.AutodateField{
		Name:     "updated",
		OnCreate: true,
		OnUpdate: true,
	})

	// Save collection
	err = c.App.Save(collection)
	if err != nil {
		return err
	}

	return nil
}

// Helper functions to update existing collections with missing fields

func updateUsersCollectionFields(app core.App, collection *core.Collection) error {
	fieldsToAdd := []core.Field{}

	// Check for missing name field
	if collection.Fields.GetByName("name") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.TextField{
			Name:     "name",
			Required: false,
			Max:      255,
			Min:      0,
		})
	}

	// Check for missing avatar field
	if collection.Fields.GetByName("avatar") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.FileField{
			Name:      "avatar",
			Required:  false,
			MaxSelect: 1,
			MaxSize:   0,
			MimeTypes: []string{
				"image/jpeg",
				"image/png",
				"image/svg+xml",
				"image/gif",
				"image/webp",
			},
			Protected: false,
		})
	}

	// Check for missing created field
	if collection.Fields.GetByName("created") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "created",
			OnCreate: true,
			OnUpdate: false,
		})
	}

	// Check for missing updated field
	if collection.Fields.GetByName("updated") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})
	}

	// Add missing fields
	for _, field := range fieldsToAdd {
		collection.Fields.Add(field)
	}

	// Save if there were missing fields
	if len(fieldsToAdd) > 0 {
		return app.Save(collection)
	}

	return nil
}

func updateChatCollectionFields(app core.App, collection *core.Collection) error {
	fieldsToAdd := []core.Field{}

	// Check for missing title field
	if collection.Fields.GetByName("title") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.TextField{
			Name:     "title",
			Required: false,
			Max:      0,
			Min:      0,
		})
	}

	// Check for missing project relation field
	if collection.Fields.GetByName("project") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.RelationField{
			Name:          "project",
			Required:      false,
			MaxSelect:     1,
			MinSelect:     0,
			CascadeDelete: false,
			CollectionId:  "pbc_3853224427",
		})
	}

	// Check for missing created field
	if collection.Fields.GetByName("created") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "created",
			OnCreate: true,
			OnUpdate: false,
		})
	}

	// Check for missing updated field
	if collection.Fields.GetByName("updated") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})
	}

	// Add missing fields
	for _, field := range fieldsToAdd {
		collection.Fields.Add(field)
	}

	// Save if there were missing fields
	if len(fieldsToAdd) > 0 {
		return app.Save(collection)
	}

	return nil
}

func updateMessageCollectionFields(app core.App, collection *core.Collection) error {
	fieldsToAdd := []core.Field{}

	// Check for missing role field
	if collection.Fields.GetByName("role") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.TextField{
			Name:     "role",
			Required: false,
			Max:      0,
			Min:      0,
		})
	}

	// Check for missing content field
	if collection.Fields.GetByName("content") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.TextField{
			Name:     "content",
			Required: false,
			Max:      0,
			Min:      0,
		})
	}

	// Check for missing chat relation field
	if collection.Fields.GetByName("chat") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.RelationField{
			Name:          "chat",
			Required:      false,
			MaxSelect:     1,
			MinSelect:     0,
			CascadeDelete: false,
			CollectionId:  "pbc_3802282532",
		})
	}

	// Check for missing created field
	if collection.Fields.GetByName("created") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "created",
			OnCreate: true,
			OnUpdate: false,
		})
	}

	// Check for missing updated field
	if collection.Fields.GetByName("updated") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})
	}

	// Add missing fields
	for _, field := range fieldsToAdd {
		collection.Fields.Add(field)
	}

	// Save if there were missing fields
	if len(fieldsToAdd) > 0 {
		return app.Save(collection)
	}

	return nil
}

func updateProjectAddressCollectionFields(app core.App, collection *core.Collection) error {
	fieldsToAdd := []core.Field{}

	// Check for missing project relation field
	if collection.Fields.GetByName("project") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.RelationField{
			Name:          "project",
			Required:      false,
			MaxSelect:     1,
			MinSelect:     0,
			CascadeDelete: false,
			CollectionId:  "pbc_3853224427",
		})
	}

	// Check for missing url field
	if collection.Fields.GetByName("url") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.URLField{
			Name:          "url",
			Required:      false,
			ExceptDomains: nil,
			OnlyDomains:   nil,
		})
	}

	// Check for missing pid field
	if collection.Fields.GetByName("pid") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.TextField{
			Name:     "pid",
			Required: false,
			Max:      0,
			Min:      0,
		})
	}

	// Check for missing created field
	if collection.Fields.GetByName("created") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "created",
			OnCreate: true,
			OnUpdate: false,
		})
	}

	// Check for missing updated field
	if collection.Fields.GetByName("updated") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})
	}

	// Add missing fields
	for _, field := range fieldsToAdd {
		collection.Fields.Add(field)
	}

	// Save if there were missing fields
	if len(fieldsToAdd) > 0 {
		return app.Save(collection)
	}

	return nil
}

func updateProjectsCollectionFields(app core.App, collection *core.Collection) error {
	fieldsToAdd := []core.Field{}

	// Check for missing projectName field
	if collection.Fields.GetByName("projectName") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.TextField{
			Name:     "projectName",
			Required: false,
			Max:      0,
			Min:      0,
		})
	}

	// Check for missing projectStructure field
	if collection.Fields.GetByName("projectStructure") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.JSONField{
			Name:     "projectStructure",
			Required: false,
			MaxSize:  0,
		})
	}

	// Check for missing routers field
	if collection.Fields.GetByName("routers") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.JSONField{
			Name:     "routers",
			Required: false,
			MaxSize:  0,
		})
	}

	// Check for missing user relation field
	if collection.Fields.GetByName("user") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.RelationField{
			Name:          "user",
			Required:      false,
			MaxSelect:     1,
			MinSelect:     0,
			CascadeDelete: false,
			CollectionId:  "_pb_users_auth_",
		})
	}

	// Check for missing created field
	if collection.Fields.GetByName("created") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "created",
			OnCreate: true,
			OnUpdate: false,
		})
	}

	// Check for missing updated field
	if collection.Fields.GetByName("updated") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})
	}

	// Add missing fields
	for _, field := range fieldsToAdd {
		collection.Fields.Add(field)
	}

	// Save if there were missing fields
	if len(fieldsToAdd) > 0 {
		return app.Save(collection)
	}

	return nil
}

func updateReferencesCollectionFields(app core.App, collection *core.Collection) error {
	fieldsToAdd := []core.Field{}

	// Check for missing project relation field
	if collection.Fields.GetByName("project") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.RelationField{
			Name:          "project",
			Required:      false,
			MaxSelect:     1,
			MinSelect:     0,
			CascadeDelete: false,
			CollectionId:  "pbc_3853224427",
		})
	}

	// Check for missing reference field
	if collection.Fields.GetByName("reference") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.JSONField{
			Name:     "reference",
			Required: false,
			MaxSize:  0,
		})
	}

	// Check for missing created field
	if collection.Fields.GetByName("created") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "created",
			OnCreate: true,
			OnUpdate: false,
		})
	}

	// Check for missing updated field
	if collection.Fields.GetByName("updated") == nil {
		fieldsToAdd = append(fieldsToAdd, &core.AutodateField{
			Name:     "updated",
			OnCreate: true,
			OnUpdate: true,
		})
	}

	// Add missing fields
	for _, field := range fieldsToAdd {
		collection.Fields.Add(field)
	}

	// Save if there were missing fields
	if len(fieldsToAdd) > 0 {
		return app.Save(collection)
	}

	return nil
}

// CreateAllCollections creates all collections in the correct order
func CreateAllCollections(app *core.RequestEvent) error {
	// Create users collection first (as it's referenced by projects)
	if err := CreateUsersCollection(app); err != nil {
		return err
	}

	// Create projects collection (referenced by other collections)
	if err := CreateProjectsCollection(app); err != nil {
		return err
	}

	// Create chat collection (referenced by message)
	if err := CreateChatCollection(app); err != nil {
		return err
	}

	// Create remaining collections
	if err := CreateMessageCollection(app); err != nil {
		return err
	}

	if err := CreateProjectAddressCollection(app); err != nil {
		return err
	}

	if err := CreateReferencesCollection(app); err != nil {
		return err
	}

	return nil
}
