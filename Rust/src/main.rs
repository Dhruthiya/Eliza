mod cli;
mod decomposer;
mod engine;
mod parser;
mod script;
mod state;
mod transformer;
mod web_server;

use parser::ScriptLoader;
use std::path::Path;
use std::env;

#[tokio::main]
async fn main() {
    let args: Vec<String> = env::args().collect();
    
    if args.contains(&"--web".to_string()) {
        web_server::start_server().await;
    } else {
        let script_path = Path::new("/home/cse/eliza/data");
        match ScriptLoader::load_from_directory(script_path) {
            Ok(script) => {
                let engine = engine::ElizaEngine::new(script, false);
                cli::run_repl(engine);
            }
            Err(e) => {
                eprintln!("Failed to load ELIZA script: {}", e);
                std::process::exit(1);
            }
        }
    }
}
