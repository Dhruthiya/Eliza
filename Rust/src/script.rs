use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Represents a single decomposition/reassembly rule
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Rule {
    /// Pattern tokens for matching (e.g., ["*", "I", "am", "*"])
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
}

impl Script {
    /// Get keyword by name
    pub fn get_keyword(&self, name: &str) -> Option<&Keyword> {
        self.keywords.get(name)
    }
    
    /// Get all keywords sorted by rank (descending)
    pub fn keywords_by_rank(&self) -> Vec<&Keyword> {
        let mut keywords: Vec<&Keyword> = self.keywords.values().collect();
        keywords.sort_by(|a, b| b.rank.cmp(&a.rank).then(a.name.cmp(&b.name)));
        keywords
    }
}
