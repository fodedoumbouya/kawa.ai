package hotrestartchannel

import (
	"fmt"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
	"github.com/pocketbase/pocketbase/core"
)

var MessageChannel = make(chan string)

// Upgrader to upgrade HTTP connection to WebSocket
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

// Subscriber is a connected WebSocket client
type Subscriber struct {
	conn *websocket.Conn
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

func (sm *SubscriberManager) broadcast(message string) {
	sm.mux.Lock()
	defer sm.mux.Unlock()
	for subscriber := range sm.subscribers {
		err := subscriber.conn.WriteMessage(websocket.TextMessage, []byte(message))
		if err != nil {
			subscriber.conn.Close()
			delete(sm.subscribers, subscriber)
		}
	}
}

var manager = &SubscriberManager{subscribers: make(map[*Subscriber]bool)}

func SendHotReload(message string) {
	MessageChannel <- message

}

// field Writer gin.ResponseWriter
func SubscribeHoReloard(c *core.RequestEvent) error {
	conn, err := upgrader.Upgrade(c.Response, c.Request, nil)
	fmt.Println("SubscribeHoReloard")
	if err != nil {
		return c.JSON(http.StatusInternalServerError, "Failed to upgrade connection")
	}
	subscriber := &Subscriber{conn: conn}
	manager.addSubscriber(subscriber)
	defer manager.removeSubscriber(subscriber)

	for {
		_, p, err := conn.ReadMessage()
		if err != nil {
			break
		}
		fmt.Printf("Message received by subscriber: %s\n", p)
	}
	return nil
}

func SendHotReloadExterne(c *core.RequestEvent) error {
	var request struct {
		Code   string `json:"code"`
		Screen string `json:"screen"`
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
	SendHotReload(msg)
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
