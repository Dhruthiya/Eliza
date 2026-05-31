package web

import (
	"encoding/json"
	"fmt"
	"net/http"
	"path/filepath"

	"eliza-go/internal/engine"
)

type Server struct {
	engine  *engine.Engine
	webRoot string
}

type chatRequest struct {
	Message string `json:"message"`
}

type chatResponse struct {
	Response string `json:"response"`
}

func NewServer(eliza *engine.Engine, projectRoot string) *Server {
	return &Server{
		engine:  eliza,
		webRoot: filepath.Join(projectRoot, "web"),
	}
}

func (s *Server) ListenAndServe(port int) error {
	mux := http.NewServeMux()
	mux.HandleFunc("/", s.handleIndex)
	mux.HandleFunc("/chat", s.handleChat)
	mux.HandleFunc("/reset", s.handleReset)
	mux.HandleFunc("/healthz", s.handleHealth)

	fmt.Println()
	fmt.Println("╔════════════════════════════════════════╗")
	fmt.Println("║     ELIZA Go Web Server Started!      ║")
	fmt.Println("╚════════════════════════════════════════╝")
	fmt.Println()
	fmt.Printf("Open: http://localhost:%d\n", port)
	fmt.Println("Press Ctrl+C to stop")
	fmt.Println()

	return http.ListenAndServe(fmt.Sprintf(":%d", port), mux)
}

func (s *Server) handleIndex(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" || r.Method != http.MethodGet {
		http.NotFound(w, r)
		return
	}
	http.ServeFile(w, r, filepath.Join(s.webRoot, "index.html"))
}

func (s *Server) handleChat(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req chatRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid JSON body", http.StatusBadRequest)
		return
	}

	response, _, err := s.engine.Transform(req.Message)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(chatResponse{Response: response})
}

func (s *Server) handleReset(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		return
	}
	s.engine.Reset()
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}

func (s *Server) handleHealth(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]string{"status": "ok"})
}
