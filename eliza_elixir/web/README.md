# ELIZA Web Frontend

## Quick Start

1. **Start the server:**
   ```bash
   cd /home/cse/eliza/eliza_elixir/web
   ./server.exs
   ```

2. **Open in browser:**
   ```
   http://localhost:4000
   ```

3. **Start chatting!**

## Features
- ✅ Retro terminal-style UI
- ✅ Real-time chat interface
- ✅ Full ELIZA engine integration
- ✅ Keyboard shortcuts (Enter to send)

## Files
- `index.html` - Frontend interface
- `server.exs` - Backend API server

## How It Works
- Frontend sends messages to `POST /chat`
- Server processes with ELIZA engine
- Response displayed in chat window
