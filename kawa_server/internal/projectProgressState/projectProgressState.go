package projectprogressstate

import (
	"fmt"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
	"github.com/pocketbase/pocketbase/core"
)

type ProjectProgressState string

const (
	// not started
	NotStarted ProjectProgressState = "Not Started"
	// creating project plan in progress
	CreatingProjectPlan ProjectProgressState = "Creating_Project_Plan"
	// created project plan
	CreatedProject ProjectProgressState = "Created_Project"
	// creating project
	CreatingProject ProjectProgressState = "Creating_Project"
	// failed to create project
	FailedToCreateProject ProjectProgressState = "Failed_To_Create_Project"
	// created project navigation flow
	CreatedProjectNavigationFlow ProjectProgressState = "Created_Project_Navigation_Flow"
	// creating project navigation flow
	CreatedingProjectNavigationFlow ProjectProgressState = "Creating_Project_Navigation_Flow"
	// failed to create project navigation flow
	FailedToCreateProjectNavigationFlow ProjectProgressState = "Failed_To_Create_Project_Navigation_Flow"
	// createdproject plan
	CreatedProjectPlan ProjectProgressState = "Created_Project_Plan"
	// failed to create project plan
	FailedToCreateProjectPlan ProjectProgressState = "Failed_To_Create_Project_Plan"
	// created project structure
	CreatedProjectStructure ProjectProgressState = "Created_Project_Structure"
	// failed to create project structure
	FailedToCreateProjectStructure ProjectProgressState = "Failed_To_Create_Project_Structure"
	// created project screens
	CreatedProjectScreens ProjectProgressState = "Created_Project_Screens"
	// failed to create project screens
	FailedToCreateProjectScreens ProjectProgressState = "Failed_To_Create_Project_Screens"
	// project launched
	ProjectLaunched ProjectProgressState = "Project_Launched"
	// failed to launch project
	FailedToLaunchProject ProjectProgressState = "Failed_To_Launch_Project"
	// creating project Navigation screens
	CreatingProjectNavigationStructure ProjectProgressState = "Creating_Project_Navigation_Structure"
	// created project Navigation structure
	CreatedProjectNavigationStructure ProjectProgressState = "Created_Project_Navigation_Structure"
	// failed to create project Navigation structure
	FailedToCreateProjectNavigationStructure ProjectProgressState = "Failed_To_Create_Project_Navigation_Structure"
	// creating flutter project
	CreatingFlutterProject ProjectProgressState = "Creating_Flutter_Project"
	// failed to create flutter project
	FailedToCreateFlutterProject ProjectProgressState = "Failed_To_Create_Flutter_Project"
	// created flutter project
	CreatedFlutterProject ProjectProgressState = "Created_Flutter_Project"
	// Launching project
	LaunchingProject ProjectProgressState = "Launching_Project"
)

// ProgressMessage will carry clientID and the progress state
type ProgressMessage struct {
	ClientID string
	State    ProjectProgressState
}

// ProjectChannel is the channel for broadcasting messages
var ProjectChannel = make(chan ProgressMessage)

// Upgrader to upgrade HTTP connection to WebSocket
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// Subscriber is a connected WebSocket client
type Subscriber struct {
	conn     *websocket.Conn
	ClientID string // Added ClientID
}

// SubscriberManager manages connected subscribers
type SubscriberManager struct {
	// subscribers map[*Subscriber]bool // Old: map of subscriber pointers
	subscribers map[string]map[*websocket.Conn]bool // New: map ClientID to a set of connections
	mux         sync.Mutex
}

func (sm *SubscriberManager) addSubscriber(clientID string, conn *websocket.Conn) {
	sm.mux.Lock()
	defer sm.mux.Unlock()
	if _, ok := sm.subscribers[clientID]; !ok {
		sm.subscribers[clientID] = make(map[*websocket.Conn]bool)
	}
	sm.subscribers[clientID][conn] = true
	fmt.Printf("Added subscriber for ClientID: %s\n", clientID)
}

func (sm *SubscriberManager) removeSubscriber(clientID string, conn *websocket.Conn) {
	sm.mux.Lock()
	defer sm.mux.Unlock()
	if conns, ok := sm.subscribers[clientID]; ok {
		delete(conns, conn)
		if len(conns) == 0 {
			delete(sm.subscribers, clientID)
			fmt.Printf("Removed last subscriber for ClientID: %s, removing clientID entry\n", clientID)
		} else {
			fmt.Printf("Removed subscriber for ClientID: %s, %d remaining\n", clientID, len(conns))
		}
	} else {
		fmt.Printf("No subscribers found for ClientID: %s to remove\n", clientID)
	}
}

func (sm *SubscriberManager) sendMessageToClient(clientID string, message ProjectProgressState) {
	sm.mux.Lock()
	defer sm.mux.Unlock()

	if conns, ok := sm.subscribers[clientID]; ok {
		fmt.Printf("Sending message '%s' to ClientID: %s (%d connections)\n", message, clientID, len(conns))
		for conn := range conns {
			err := conn.WriteMessage(websocket.TextMessage, []byte(message))
			if err != nil {
				fmt.Printf("Error writing message to ClientID %s: %v. Closing connection.\n", clientID, err)
				conn.Close()
				// It's important to remove the connection from the map here as well
				// This part of removeSubscriber logic needs to be carefully integrated or called
				delete(sm.subscribers[clientID], conn) // Simplified removal, consider full removeSubscriber logic if complex
				if len(sm.subscribers[clientID]) == 0 {
					delete(sm.subscribers, clientID)
				}
			}
		}
	} else {
		fmt.Printf("No subscribers found for ClientID: %s to send message '%s'\n", clientID, message)
	}
}

var manager = &SubscriberManager{subscribers: make(map[string]map[*websocket.Conn]bool)} // Initialize new structure

func SendProjectProgress(clientID string, message ProjectProgressState) {
	if clientID == "" {
		fmt.Println("Warning: SendProjectProgress called with empty clientID. Message:", message)
		// Decide how to handle this: maybe log and drop, or have a default broadcast?
		// For now, let's log and drop if no clientID.
		return
	}
	ProjectChannel <- ProgressMessage{ClientID: clientID, State: message}
}

func SubscribeProjectProgress(c *core.RequestEvent) error {
	clientID := c.Request.URL.Query().Get("clientId") // Get clientID from query param
	if clientID == "" {
		return c.JSON(http.StatusBadRequest, "clientId query parameter is required")
	}

	conn, err := upgrader.Upgrade(c.Response, c.Request, nil)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, "Failed to upgrade connection")
	}

	// subscriber := &Subscriber{conn: conn, ClientID: clientID} // Not storing Subscriber struct directly in manager anymore
	manager.addSubscriber(clientID, conn)
	fmt.Printf("Client %s subscribed to project progress\n", clientID)
	defer func() {
		manager.removeSubscriber(clientID, conn)
		conn.Close()
		fmt.Printf("Client %s unsubscribed from project progress\n", clientID)
	}()

	for {
		_, msg, err := conn.ReadMessage()
		if err != nil {
			fmt.Printf("Client %s read error: %v. Closing connection.\n", clientID, err)
			break
		}
		fmt.Printf("Received message from client %s: %s\n", clientID, string(msg))
		// Handle client messages if necessary, e.g., keep-alive
	}
	return nil
}

func SendProjectProgressExterne(c *core.RequestEvent) error {
	var request struct {
		ClientID string `json:"clientId"` // Added ClientID
		Message  string `json:"message"`
	}
	if err := c.BindBody(&request); err != nil {
		return c.JSON(http.StatusBadRequest, "Invalid request")
	}
	if request.ClientID == "" {
		return c.JSON(http.StatusBadRequest, "clientId is required in request body")
	}
	SendProjectProgress(request.ClientID, ProjectProgressState(request.Message))
	return c.JSON(http.StatusOK, "Message sent")
}

func InitProjectProgress() {
	go func() {
		for progressMsg := range ProjectChannel {
			fmt.Printf("Processing message for ClientID %s: %s\n", progressMsg.ClientID, progressMsg.State)
			manager.sendMessageToClient(progressMsg.ClientID, progressMsg.State)
		}
	}()
}
