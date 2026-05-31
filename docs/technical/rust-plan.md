
# ELIZA - Rust Implementation Plan (Version 1.0)

This document outlines the implementation plan for creating a foundational, "historically-inspired" ELIZA engine in Rust. The primary goal of Version 1.0 is to build a robust, memory-safe, and performant core that correctly implements the essential ELIZA logic and can be tested against a known script.

---

## 1. Goal for Version 1.0

**To create a functional ELIZA engine in Rust that correctly implements the core decomposition/reassembly logic and can accurately reproduce the classic DOCTOR script conversation.**

This version will prioritize:
- Clean, idiomatic Rust code with strong type safety
- Zero-cost abstractions and memory safety without garbage collection
- A well-structured implementation based on Weizenbaum's paper and the `implementation-guide.md`
- Deterministic behavior for testing and verification

---

## 2. Why Rust?

Rust is an excellent choice for implementing ELIZA because:

- **Pattern Matching**: Rust's powerful pattern matching and enum types are ideal for implementing the decomposition logic
- **Memory Safety**: Ownership and borrowing ensure memory safety without runtime overhead
- **Performance**: Zero-cost abstractions provide C-like performance
- **Type Safety**: Strong static typing catches errors at compile time
- **Concurrency**: Built-in concurrency primitives enable future multi-user support
- **Modern Tooling**: Cargo provides excellent dependency management, testing, and documentation
- **Error Handling**: Result and Option types make error handling explicit and robust

---

## 3. Key Milestones & Phases

The project will be broken down into five distinct phases.

### Phase 1: Project Setup & Data Modeling

This phase focuses on creating the foundational structures for the project.

#### Task 1.1: Initialize Rust Project

**Action:** Set up a new Rust project with proper structure
```bash
cargo new eliza_rust --bin
cd eliza_rust
```

**Project Structure:**
```
eliza_rust/
├── Cargo.toml
├── src/
│   ├── main.rs           # CLI entry point
│   ├── lib.rs            # Library root
│   ├── script.rs         # Data structures
│   ├── parser.rs         # Script parser
│   ├── decomposer.rs     # Pattern matching engine
│   ├── transformer.rs    # Component transformation
│   ├── engine.rs         # Main engine logic
│   ├── state.rs          # Conversation state management
│   └── cli.rs            # CLI interface
├── tests/
│   ├── integration_test.rs
│   └── golden_transcript_test.rs
└── data/
    └── (JSON script files)
```

**Dependencies (Cargo.toml):**
```toml
[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
regex = "1.10"
rand = "0.8"

[dev-dependencies]
criterion = "0.5"
```

#### Task 1.2: Define Canonical Data Structures

**Goal:** Create Rust structs that represent the ELIZA script data with strong type safety.

**Action:** Define the following in `src/script.rs`:

```rust
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Represents a single decomposition/reassembly rule
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Rule {
    /// Pattern tokens for matching (e.g., ["0", "I", "are", "0"])
    pub pattern: Vec<String>,
    
    /// List of possible reassembly templates
    pub reassembly: Vec<String>,
    
    /// Whether this rule should save to memory
    #[serde(default)]
    pub is_memory_rule: bool,
    
    /// Optional goto keyword for redirection
    #[serde(skip_serializing_if = "Option::is_none")]
    pub goto: Option<String>,
}

/// Represents a keyword with its rank and associated rules
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Keyword {
    pub name: String,
    pub rank: u32,
    pub rules: Vec<Rule>,
}

/// Main script structure containing all ELIZA data
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Script {
    /// Initial greetings
    pub initials: Vec<String>,
    
    /// Final farewells
    pub finals: Vec<String>,
    
    /// Quit words
    pub quits: Vec<String>,
    
    /// Pre-transformation map (input normalization)
    pub pres: HashMap<String, String>,
    
    /// Post-transformation map (pronoun swapping)
    pub posts: HashMap<String, String>,
    
    /// Synonym groups
    pub synons: HashMap<String, Vec<String>>,
    
    /// Keywords mapped by name
    pub keywords: HashMap<String, Keyword>,
    
    /// Additional post-transforms (if needed)
    #[serde(default)]
    pub post_transforms: Vec<(String, String)>,
}

impl Script {
    /// Get keyword by name
    pub fn get_keyword(&self, name: &str) -> Option<&Keyword> {
        self.keywords.get(name)
    }
    
    /// Get all keywords sorted by rank (descending)
    pub fn keywords_by_rank(&self) -> Vec<&Keyword> {
        let mut keywords: Vec<&Keyword> = self.keywords.values().collect();
        keywords.sort_by(|a, b| b.rank.cmp(&a.rank));
        keywords
    }
}
```

#### Task 1.3: Implement Script Parser

**Goal:** Create a parser that loads JSON script files into Rust structs.

**Action:** Implement in `src/parser.rs`:

```rust
use crate::script::Script;
use std::fs;
use std::path::Path;

#[derive(Debug)]
pub enum ParseError {
    IoError(std::io::Error),
    JsonError(serde_json::Error),
}

impl From<std::io::Error> for ParseError {
    fn from(err: std::io::Error) -> Self {
        ParseError::IoError(err)
    }
}

impl From<serde_json::Error> for ParseError {
    fn from(err: serde_json::Error) -> Self {
        ParseError::JsonError(err)
    }
}

pub struct ScriptLoader;

impl ScriptLoader {
    /// Load script from multiple JSON files
    pub fn load_from_directory(dir: &Path) -> Result<Script, ParseError> {
        // Load individual JSON files
        let initials = Self::load_json_file(dir.join("elizaInitials.json"))?;
        let finals = Self::load_json_file(dir.join("elizaFinals.json"))?;
        let quits = Self::load_json_file(dir.join("elizaQuits.json"))?;
        let pres = Self::load_json_file(dir.join("elizaPres.json"))?;
        let posts = Self::load_json_file(dir.join("elizaPosts.json"))?;
        let synons = Self::load_json_file(dir.join("elizaSynons.json"))?;
        let keywords = Self::load_json_file(dir.join("elizaKeywords.json"))?;
        
        Ok(Script {
            initials,
            finals,
            quits,
            pres,
            posts,
            synons,
            keywords,
            post_transforms: vec![],
        })
    }
    
    fn load_json_file<T: serde::de::DeserializeOwned>(path: impl AsRef<Path>) -> Result<T, ParseError> {
        let content = fs::read_to_string(path)?;
        let data = serde_json::from_str(&content)?;
        Ok(data)
    }
}
```

---

### Phase 2: The Decomposition Engine

This is the most complex phase, focusing on the core pattern-matching logic.

#### Task 2.1: Implement Wildcard Matching Algorithm

**Goal:** Implement the recursive, backtracking algorithm for pattern matching.

**Action:** Create in `src/decomposer.rs`:

```rust
/// Result of a successful decomposition
#[derive(Debug, Clone)]
pub struct DecompositionResult {
    pub components: Vec<String>,
}

pub struct Decomposer;

impl Decomposer {
    /// Main entry point for decomposition
    pub fn decompose(sentence: &[String], pattern: &[String]) -> Option<DecompositionResult> {
        let components = Self::match_recursive(sentence, pattern, Vec::new())?;
        Some(DecompositionResult { components })
    }
    
    /// Recursive matching with backtracking
    fn match_recursive(
        sentence: &[String],
        pattern: &[String],
        mut components: Vec<String>,
    ) -> Option<Vec<String>> {
        // Base case: both empty - success
        if sentence.is_empty() && pattern.is_empty() {
            return Some(components);
        }
        
        // Base case: pattern empty but sentence not (unless trailing wildcards)
        if pattern.is_empty() {
            return None;
        }
        
        // Base case: sentence empty but pattern not
        if sentence.is_empty() {
            // Only succeed if remaining pattern is all "0" wildcards
            if pattern.iter().all(|t| t == "0") {
                for _ in pattern {
                    components.push(String::new());
                }
                return Some(components);
            }
            return None;
        }
        
        let token = &pattern[0];
        
        // Case 1: Literal keyword match
        if token != "0" && !token.chars().all(|c| c.is_ascii_digit()) {
            if sentence[0].eq_ignore_ascii_case(token) {
                components.push(token.clone());
                return Self::match_recursive(&sentence[1..], &pattern[1..], components);
            }
            return None;
        }
        
        // Case 2: Fixed-length wildcard (e.g., "1", "2", "3")
        if let Ok(n) = token.parse::<usize>() {
            if n > 0 && sentence.len() >= n {
                let component = sentence[..n].join(" ");
                components.push(component);
                return Self::match_recursive(&sentence[n..], &pattern[1..], components);
            }
            return None;
        }
        
        // Case 3: Indefinite wildcard "0" - backtracking
        if token == "0" {
            // Try matching 0 to len(sentence) words
            for i in 0..=sentence.len() {
                let component = if i == 0 {
                    String::new()
                } else {
                    sentence[..i].join(" ")
                };
                
                let mut new_components = components.clone();
                new_components.push(component);
                
                if let Some(result) = Self::match_recursive(&sentence[i..], &pattern[1..], new_components) {
                    return Some(result);
                }
            }
        }
        
        None
    }
}
```

#### Task 2.2: Add Synonym Support

**Action:** Extend decomposer to handle `@synon` patterns:

```rust
impl Decomposer {
    /// Check if a word matches a pattern token (including synonyms)
    fn matches_token(word: &str, token: &str, synons: &HashMap<String, Vec<String>>) -> bool {
        if token.starts_with('@') {
            // Synonym class
            let class = &token[1..];
            if let Some(synonyms) = synons.get(class) {
                return synonyms.iter().any(|s| s.eq_ignore_ascii_case(word));
            }
            false
        } else {
            word.eq_ignore_ascii_case(token)
        }
    }
}
```

---

### Phase 3: Transformation & Reassembly

This phase focuses on constructing the response from decomposed parts.

#### Task 3.1: Implement Component Transformation

**Goal:** Implement pronoun-swapping logic.

**Action:** Create in `src/transformer.rs`:

```rust
use std::collections::HashMap;

pub struct Transformer;

impl Transformer {
    /// Transform components using post-transformation map
    pub fn transform_components(
        components: &[String],
        posts: &HashMap<String, String>,
    ) -> Vec<String> {
        components
            .iter()
            .map(|component| Self::transform_component(component, posts))
            .collect()
    }
    
    /// Transform a single component
    fn transform_component(component: &str, posts: &HashMap<String, String>) -> String {
        component
            .split_whitespace()
            .map(|word| {
                posts
                    .get(&word.to_lowercase())
                    .map(|s| s.as_str())
                    .unwrap_or(word)
            })
            .collect::<Vec<_>>()
            .join(" ")
    }
    
    /// Reassemble response from template and transformed components
    pub fn reassemble(template: &str, components: &[String]) -> String {
        let mut result = template.to_string();
        
        // Replace placeholders (1), (2), (3), etc.
        for (i, component) in components.iter().enumerate() {
            let placeholder = format!("({})", i + 1);
            result = result.replace(&placeholder, component);
        }
        
        result
    }
}
```

---

### Phase 4: The Main Engine Loop

This phase ties all components together into a functioning engine.

#### Task 4.1: Implement Conversation State

**Goal:** Manage conversation state including memory queue and response counters.

**Action:** Create in `src/state.rs`:

```rust
use std::collections::{HashMap, VecDeque};

pub struct ConversationState {
    /// Memory queue (FIFO)
    memory: VecDeque<String>,
    
    /// Maximum memory size
    max_memory: usize,
    
    /// Response counters for cyclic selection
    response_counters: HashMap<String, usize>,
    
    /// Whether to use random selection
    use_random: bool,
}

impl ConversationState {
    pub fn new(max_memory: usize, use_random: bool) -> Self {
        Self {
            memory: VecDeque::with_capacity(max_memory),
            max_memory,
            response_counters: HashMap::new(),
            use_random,
        }
    }
    
    /// Add a memory
    pub fn add_memory(&mut self, response: String) {
        if self.memory.len() >= self.max_memory {
            self.memory.pop_front();
        }
        self.memory.push_back(response);
    }
    
    /// Retrieve a memory
    pub fn get_memory(&mut self) -> Option<String> {
        if self.use_random {
            if self.memory.is_empty() {
                None
            } else {
                let idx = rand::random::<usize>() % self.memory.len();
                Some(self.memory.remove(idx).unwrap())
            }
        } else {
            self.memory.pop_front()
        }
    }
    
    /// Select a reassembly template (cyclic or random)
    pub fn select_reassembly(&mut self, rule_id: &str, templates: &[String]) -> Option<String> {
        if templates.is_empty() {
            return None;
        }
        
        if self.use_random {
            let idx = rand::random::<usize>() % templates.len();
            Some(templates[idx].clone())
        } else {
            let counter = self.response_counters.entry(rule_id.to_string()).or_insert(0);
            let idx = *counter % templates.len();
            *counter += 1;
            Some(templates[idx].clone())
        }
    }
}
```

#### Task 4.2: Implement Main Engine

**Goal:** Create the main transform function that orchestrates the entire process.

**Action:** Create in `src/engine.rs`:

```rust
use crate::decomposer::{Decomposer, DecompositionResult};
use crate::script::Script;
use crate::state::ConversationState;
use crate::transformer::Transformer;

pub struct ElizaEngine {
    script: Script,
    state: ConversationState,
}

impl ElizaEngine {
    pub fn new(script: Script, use_random: bool) -> Self {
        Self {
            script,
            state: ConversationState::new(20, use_random),
        }
    }
    
    /// Main transform function
    pub fn transform(&mut self, input: &str) -> String {
        // Normalize input
        let normalized = self.normalize_input(input);
        let words: Vec<String> = normalized
            .split_whitespace()
            .map(|s| s.to_string())
            .collect();
        
        // Check for quit words
        if self.is_quit(&words) {
            return self.get_final();
        }
        
        // Find highest-ranking keyword and try to match
        for keyword in self.script.keywords_by_rank() {
            if let Some(response) = self.try_keyword(&words, keyword) {
                return response;
            }
        }
        
        // No match found - try memory
        if let Some(memory) = self.state.get_memory() {
            return memory;
        }
        
        // Fallback to generic response
        self.get_generic_response()
    }
    
    /// Normalize input using pre-transformation map
    fn normalize_input(&self, input: &str) -> String {
        let mut result = input.to_lowercase();
        for (from, to) in &self.script.pres {
            result = result.replace(from, to);
        }
        result
    }
    
    /// Check if input contains quit word
    fn is_quit(&self, words: &[String]) -> bool {
        words.iter().any(|w| self.script.quits.contains(w))
    }
    
    /// Try to match against a keyword's rules
    fn try_keyword(&mut self, words: &[String], keyword: &crate::script::Keyword) -> Option<String> {
        for (rule_idx, rule) in keyword.rules.iter().enumerate() {
            // Handle goto
            if let Some(goto_keyword) = &rule.goto {
                if let Some(target) = self.script.get_keyword(goto_keyword) {
                    return self.try_keyword(words, target);
                }
            }
            
            // Try to decompose
            if let Some(decomp) = Decomposer::decompose(words, &rule.pattern) {
                return Some(self.generate_response(keyword, rule_idx, rule, decomp));
            }
        }
        None
    }
    
    /// Generate response from matched rule
    fn generate_response(
        &mut self,
        keyword: &crate::script::Keyword,
        rule_idx: usize,
        rule: &crate::script::Rule,
        decomp: DecompositionResult,
    ) -> String {
        // Transform components
        let transformed = Transformer::transform_components(&decomp.components, &self.script.posts);
        
        // Select reassembly template
        let rule_id = format!("{}:{}", keyword.name, rule_idx);
        let template = self.state
            .select_reassembly(&rule_id, &rule.reassembly)
            .unwrap_or_else(|| "I see.".to_string());
        
        // Reassemble response
        let response = Transformer::reassemble(&template, &transformed);
        
        // Save to memory if needed
        if rule.is_memory_rule {
            self.state.add_memory(response.clone());
        }
        
        response
    }
    
    fn get_final(&self) -> String {
        self.script.finals.first()
            .cloned()
            .unwrap_or_else(|| "Goodbye.".to_string())
    }
    
    fn get_generic_response(&self) -> String {
        "Please go on.".to_string()
    }
    
    pub fn get_initial(&self) -> String {
        self.script.initials.first()
            .cloned()
            .unwrap_or_else(|| "Hello.".to_string())
    }
}
```

---

### Phase 5: Interface and Testing

#### Task 5.1: Create Command-Line Interface

**Goal:** Create a REPL for interacting with ELIZA.

**Action:** Implement in `src/cli.rs` and `src/main.rs`:

```rust
// src/cli.rs
use crate::engine::ElizaEngine;
use std::io::{self, Write};

pub fn run_repl(mut engine: ElizaEngine) {
    println!("{}", engine.get_initial());
    
    loop {
        print!("> ");
        io::stdout().flush().unwrap();
        
        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
        
        let input = input.trim();
        if input.is_empty() {
            continue;
        }
        
        let response = engine.transform(input);
        println!("{}", response);
        
        // Check if conversation ended
        if input.to_lowercase().contains("goodbye") {
            break;
        }
    }
}

// src/main.rs
mod cli;
mod decomposer;
mod engine;
mod parser;
mod script;
mod state;
mod transformer;

use parser::ScriptLoader;
use std::path::Path;

fn main() {
    let script = ScriptLoader::load_from_directory(Path::new("../data"))
        .expect("Failed to load script");
    
    let engine = engine::ElizaEngine::new(script, false);
    cli::run_repl(engine);
}
```

#### Task 5.2: Create Golden Transcript Test

**Goal:** Verify implementation correctness against known conversation.

**Action:** Create in `tests/golden_transcript_test.rs`:

```rust
use eliza_rust::engine::ElizaEngine;
use eliza_rust::parser::ScriptLoader;
use std::path::Path;

#[test]
fn test_golden_transcript() {
    let script = ScriptLoader::load_from_directory(Path::new("../data"))
        .expect("Failed to load script");
    
    let mut engine = ElizaEngine::new(script, false);
    
    // Test cases from Weizenbaum's original conversation
    let test_cases = vec![
        ("Men are all alike.", "IN WHAT WAY"),
        ("They're always bugging us about something or other.", "CAN YOU THINK OF A SPECIFIC EXAMPLE"),
        // Add more test cases from eliza_test.html
    ];
    
    for (input, expected) in test_cases {
        let response = engine.transform(input);
        assert_eq!(
            response.to_uppercase(),
            expected,
            "Failed for input: {}",
            input
        );
    }
}
```

#### Task 5.3: Add Unit Tests

**Action:** Add comprehensive unit tests for each module:

```rust
// In src/decomposer.rs
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_simple_wildcard() {
        let sentence = vec!["i".to_string(), "am".to_string(), "sad".to_string()];
        let pattern = vec!["0".to_string(), "i".to_string(), "am".to_string(), "0".to_string()];
        
        let result = Decomposer::decompose(&sentence, &pattern).unwrap();
        assert_eq!(result.components.len(), 4);
        assert_eq!(result.components[0], "");
        assert_eq!(result.components[1], "i");
        assert_eq!(result.components[2], "am");
        assert_eq!(result.components[3], "sad");
    }
}
```

---

## 4. Definition of Done for Version 1.0

Version 1.0 will be considered complete when:

- ✅ The engine can successfully parse and load JSON script files into Rust structs
- ✅ The decomposition engine correctly implements the backtracking wildcard algorithm
- ✅ Component transformation and reassembly work correctly
- ✅ The main engine orchestrates all components properly
- ✅ Memory queue and response selection work as specified
- ✅ All unit tests pass
- ✅ The golden transcript test passes, proving accurate reproduction of classic conversations
- ✅ A user can interact with DOCTOR via the CLI
- ✅ Code compiles without warnings with `cargo clippy`
- ✅ Code is properly formatted with `cargo fmt`
- ✅ Documentation is complete with `cargo doc`

---

## 5. Rust-Specific Best Practices

### Error Handling
- Use `Result<T, E>` for operations that can fail
- Create custom error types using `thiserror` crate
- Use `Option<T>` for optional values
- Avoid `unwrap()` in production code

### Performance Optimizations
- Use `&str` for string slices instead of `String` where possible
- Leverage zero-cost abstractions (iterators, pattern matching)
- Use `Cow<str>` for strings that might be borrowed or owned
- Profile with `cargo bench` using Criterion

### Memory Management
- Minimize cloning with borrowing
- Use `Rc<T>` or `Arc<T>` for shared ownership when needed
- Leverage move semantics for efficiency
- Use `Box<T>` for heap allocation when needed

### Concurrency (Future Enhancement)
- Use `Arc<Mutex<T>>` for shared mutable state
- Consider `tokio` for async runtime
- Each conversation can run in its own task

---

## 6. Outline for Future Versions (v2.0 and beyond)

### Version 2.0: Enhanced Features
- **Web Interface**: Add REST API using `axum` or `actix-web`
- **Async Support**: Use `tokio` for concurrent conversations
- **Persistent State**: Save conversation history to database
- **Configuration**: TOML-based configuration files

### Version 3.0: Advanced Capabilities
- **Multi-Script Support**: Load different personalities at runtime
- **Plugin System**: Dynamic loading of custom transformers
- **Metrics**: Prometheus metrics for monitoring
- **WebAssembly**: Compile to WASM for browser deployment

### Version 4.0: Modern AI Integration
- **Hybrid Mode**: Combine rule-based ELIZA with LLM fallback
- **Learning**: Track successful patterns and adapt
- **Multi-language**: Support for non-English scripts
- **Voice Interface**: Speech-to-text and text-to-speech integration

---

## 7. Development Workflow

### Setup
```bash
# Clone repository
git clone <repo-url>
cd eliza/eliza_rust

# Build project
cargo build

# Run tests
cargo test

# Run with optimizations
cargo run --release

# Check code quality
cargo clippy
cargo fmt --check

# Generate documentation
cargo doc --open
```

### Testing Strategy
1. **Unit Tests**: Test individual functions in each module
2. **Integration Tests**: Test module interactions
3. **Golden Transcript**: Verify against historical conversations
4. **Property Tests**: Use `proptest` for fuzzing
5. **Benchmarks**: Use `criterion` for performance testing

### CI/CD Pipeline
- Run tests on every commit
- Check formatting and linting
- Build for multiple platforms (Linux, macOS, Windows)
- Generate and publish documentation
- Create release binaries

---

## 8. Project Timeline

### Week 1: Foundation
- Day 1-2: Project setup and data structures
- Day 3-4: Script parser implementation
- Day 5-7: Basic decomposer with simple wildcards

### Week 2: Core Logic
- Day 8-10: Complete decomposer with backtracking
- Day 11-12: Transformer and reassembler
- Day 13-14: Main engine integration

### Week 3: Features & Testing
- Day 15-16: Memory system and state management
- Day 17-18: CLI interface
- Day 19-20: Unit tests and integration tests
- Day 21: Golden transcript test and verification

### Week 4: Polish & Documentation
- Day 22-23: Code cleanup and optimization
- Day 24-25: Documentation and examples
- Day 26-27: Performance testing and benchmarks
- Day 28: Final review and release

---

## 9. Success Metrics

- **Correctness**: 100% pass rate on golden transcript test
- **Performance**: < 1ms response time for typical inputs
- **Memory**: < 10MB memory footprint
- **Code Quality**: Zero clippy warnings, 100% formatted
- **Test Coverage**: > 80% code coverage
- **Documentation**: All public APIs documented

---

## 10. Resources and References

### Documentation
- Weizenbaum's 1966 paper (docs/weizenbaum.eliza.1966.pdf)
- Implementation guide (docs/handling-problems/wildcard/implementation-guide.md)
- Original JavaScript implementation (eliza_script/elizabot.js)

### Rust Resources
- The Rust Programming Language Book: https://doc.rust-lang.org/book/
- Rust by Example: https://doc.rust-lang.org/rust-by-example/
- Rust API Guidelines: https://rust-lang.github.io/api-guidelines/

### Testing Resources
- Rust Testing Guide: https://doc.rust-lang.org/book/ch11-00-testing.html
- Criterion Benchmarking: https://github.com/bheisler/criterion.rs

---

## Conclusion

This implementation plan provides a clear, structured path to building a robust ELIZA engine in Rust. By leveraging Rust's strengths in type safety, performance, and memory management, we can create an implementation that is both historically faithful and modern in its engineering practices.

The phased approach ensures steady progress with clear milestones, while the comprehensive testing strategy guarantees correctness. The result will be a high-quality, maintainable codebase that serves as both a working chatbot and an educational resource for understanding both ELIZA and Rust programming.
