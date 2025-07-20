package hotrestartchannel

import (
	"fmt"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
	"github.com/pocketbase/pocketbase/core"
)

// Message represents a project-specific message
type Message struct {
	Content   string
	ProjectID string
}

var MessageChannel = make(chan Message)

// Upgrader to upgrade HTTP connection to WebSocket
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// Subscriber is a connected WebSocket client
type Subscriber struct {
	conn      *websocket.Conn
	projectID string
}

// SubscriberManager manages connected subscribers
type SubscriberManager struct {
	subscribers map[*Subscriber]bool
	mux         sync.Mutex
}

func (sm *SubscriberManager) addSubscriber(s *Subscriber) {
	sm.mux.Lock()
	sm.subscribers[s] = true
	sm.mux.Unlock()
}

func (sm *SubscriberManager) removeSubscriber(s *Subscriber) {
	sm.mux.Lock()
	delete(sm.subscribers, s)
	sm.mux.Unlock()
}

func (sm *SubscriberManager) broadcast(message Message) {
	sm.mux.Lock()
	defer sm.mux.Unlock()
	for subscriber := range sm.subscribers {
		// Only send message to subscribers of the same project
		if subscriber.projectID == message.ProjectID {
			err := subscriber.conn.WriteMessage(websocket.TextMessage, []byte(message.Content))
			if err != nil {
				subscriber.conn.Close()
				delete(sm.subscribers, subscriber)
			}
		}
	}
}

var manager = &SubscriberManager{subscribers: make(map[*Subscriber]bool)}

func SendHotReload(message string, projectId string) {
	MessageChannel <- Message{
		Content:   message,
		ProjectID: projectId,
	}
}

// field Writer gin.ResponseWriter
func SubscribeHoReloard(c *core.RequestEvent) error {
	// Get project ID from query parameters
	projectID := c.Request.PathValue("projectId")
	if projectID == "" {
		return c.JSON(http.StatusBadRequest, "projectId parameter is required")
	}

	conn, err := upgrader.Upgrade(c.Response, c.Request, nil)
	fmt.Println("SubscribeHoReloard for project:", projectID)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, "Failed to upgrade connection")
	}
	subscriber := &Subscriber{conn: conn, projectID: projectID}
	manager.addSubscriber(subscriber)
	defer manager.removeSubscriber(subscriber)

	for {
		_, p, err := conn.ReadMessage()
		if err != nil {
			break
		}
		fmt.Printf("Message received by subscriber for project %s: %s\n", projectID, p)
	}
	return nil
}

func SendHotReloadExterne(c *core.RequestEvent) error {
	var request struct {
		Code      string `json:"code"`
		Screen    string `json:"screen"`
		ProjectId string `json:"projectId"`
	}
	if err := c.BindBody(&request); err != nil {
		// c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return c.JSON(http.StatusBadRequest, err.Error())
	}

	if request.Code == "" {
		// c.JSON(http.StatusBadRequest, gin.H{"error": "message field is required"})
		return c.JSON(http.StatusBadRequest, "message field is required")
	}
	msg := fmt.Sprintf(`{"code": "%s", "screen": "%s"}`, request.Code, request.Screen)
	SendHotReload(msg, request.ProjectId)
	// c.JSON(http.StatusOK, gin.H{"status": "Message sent"})
	return c.JSON(http.StatusOK, "Message sent")
}

func InitHotReload() {
	go func() {
		for message := range MessageChannel {
			manager.broadcast(message)
		}
	}()
}
