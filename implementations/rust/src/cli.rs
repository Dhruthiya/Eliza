use crate::engine::ElizaEngine;
use std::io::{self, Write};

pub fn run_repl(mut engine: ElizaEngine) {
    println!("{}", engine.get_initial());
    
    loop {
        print!("> ");
        io::stdout().flush().unwrap();
        
        let mut input = String::new();
        if io::stdin().read_line(&mut input).is_err() {
            break;
        }
        
        let input = input.trim();
        if input.is_empty() {
            continue;
        }
        
        let response = engine.transform(input);
        println!("{}", response);
        
        // Simple check for goodbye to break the loop manually if needed
        if input.to_lowercase() == "quit" || input.to_lowercase() == "exit" {
            break;
        }
        
        // The engine returns the final message when a quit word is matched,
        // but it doesn't signal the loop to end. 
        // We could check if response is in script.finals, but it's simpler to let the user decide.
    }
}
