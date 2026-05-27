use axum::{
    routing::{get, post},
    Json, Router, extract::State,
};
use serde::{Deserialize, Serialize};
use std::env;
use std::path::PathBuf;
use std::sync::{Arc, Mutex};
use tower_http::cors::CorsLayer;

use crate::engine::ElizaEngine;
use crate::parser::ScriptLoader;

#[derive(Deserialize)]
struct ChatRequest {
    message: String,
}

#[derive(Serialize)]
struct ChatResponse {
    response: String,
}

struct AppState {
    engine: Mutex<ElizaEngine>,
}

pub async fn start_server() {
    let script_path = ScriptLoader::resolve_data_directory(None).expect("Failed to locate ELIZA data directory");
    let script = ScriptLoader::load_from_directory(&script_path).expect("Failed to load script");
    let engine = ElizaEngine::new(script, false);
    
    let shared_state = Arc::new(AppState {
        engine: Mutex::new(engine),
    });

    let app = Router::new()
        .route("/", get(serve_index))
        .route("/chat", post(chat_handler))
        .layer(CorsLayer::permissive())
        .with_state(shared_state);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:4000").await.unwrap();
    println!("\n╔════════════════════════════════════════╗");
    println!("║     ELIZA Rust Web Server Started!    ║");
    println!("╚════════════════════════════════════════╝");
    println!("\n➜ Open: http://localhost:4000");
    println!("➜ Press Ctrl+C to stop\n");
    
    axum::serve(listener, app).await.unwrap();
}

async fn serve_index() -> axum::response::Html<String> {
    let html = std::fs::read_to_string(resolve_web_index()).expect("Failed to read index.html");
    axum::response::Html(html)
}

fn resolve_web_index() -> PathBuf {
    let cwd = env::current_dir().expect("Failed to determine current directory");
    let candidates = [
        cwd.join("web/index.html"),
        cwd.join("Rust/web/index.html"),
        cwd.join("../Rust/web/index.html"),
    ];

    candidates
        .into_iter()
        .find(|path| path.is_file())
        .expect("Failed to locate Rust web/index.html")
}

async fn chat_handler(
    State(state): State<Arc<AppState>>,
    Json(payload): Json<ChatRequest>,
) -> Json<ChatResponse> {
    let mut engine = state.engine.lock().unwrap();
    let response = engine.transform(&payload.message);
    Json(ChatResponse { response })
}
