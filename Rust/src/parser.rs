use crate::script::{Keyword, Rule, Script};
use serde_json::Value;
use std::collections::HashMap;
use std::fs;
use std::path::Path;

#[derive(Debug)]
pub enum ParseError {
    IoError(std::io::Error),
    JsonError(serde_json::Error),
    InvalidFormat(String),
}

impl std::fmt::Display for ParseError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ParseError::IoError(e) => write!(f, "IO Error: {}", e),
            ParseError::JsonError(e) => write!(f, "JSON Error: {}", e),
            ParseError::InvalidFormat(s) => write!(f, "Invalid Format: {}", s),
        }
    }
}

impl std::error::Error for ParseError {}

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
    pub fn load_from_directory(dir: &Path) -> Result<Script, ParseError> {
        let initials: Vec<String> = Self::load_json_file(dir.join("elizaInitials.json"))?;
        let finals: Vec<String> = Self::load_json_file(dir.join("elizaFinals.json"))?;
        let quits: Vec<String> = Self::load_json_file(dir.join("elizaQuits.json"))?;
        
        let pres_raw: Vec<Vec<String>> = Self::load_json_file(dir.join("elizaPres.json"))?;
        let pres = pres_raw.into_iter().filter(|v| v.len() == 2).map(|v| (v[0].clone(), v[1].clone())).collect();
        
        let posts_raw: Vec<Vec<String>> = Self::load_json_file(dir.join("elizaPosts.json"))?;
        let posts = posts_raw.into_iter().filter(|v| v.len() == 2).map(|v| (v[0].clone(), v[1].clone())).collect();
        
        let synons: HashMap<String, Vec<String>> = Self::load_json_file(dir.join("elizaSynons.json"))?;
        
        let keywords_raw: Value = Self::load_json_file(dir.join("elizaKeywords.json"))?;
        let keywords = Self::parse_keywords(keywords_raw)?;
        
        Ok(Script {
            initials,
            finals,
            quits,
            pres,
            posts,
            synons,
            keywords,
        })
    }
    
    fn load_json_file<T: serde::de::DeserializeOwned>(path: impl AsRef<Path>) -> Result<T, ParseError> {
        let content = fs::read_to_string(path)?;
        let data = serde_json::from_str(&content)?;
        Ok(data)
    }
    
    fn parse_keywords(raw: Value) -> Result<HashMap<String, Keyword>, ParseError> {
        let mut keywords = HashMap::new();
        
        let arr = raw.as_array().ok_or_else(|| ParseError::InvalidFormat("Keywords must be an array".to_string()))?;
        
        for item in arr {
            let kw_arr = item.as_array().ok_or_else(|| ParseError::InvalidFormat("Keyword item must be an array".to_string()))?;
            if kw_arr.len() < 3 {
                continue;
            }
            
            let name = kw_arr[0].as_str().ok_or_else(|| ParseError::InvalidFormat("Keyword name must be a string".to_string()))?.to_string();
            let rank = kw_arr[1].as_u64().ok_or_else(|| ParseError::InvalidFormat("Keyword rank must be a number".to_string()))? as u32;
            let rules_arr = kw_arr[2].as_array().ok_or_else(|| ParseError::InvalidFormat("Keyword rules must be an array".to_string()))?;
            
            let mut rules = Vec::new();
            for rule_item in rules_arr {
                let rule_arr = rule_item.as_array().ok_or_else(|| ParseError::InvalidFormat("Rule item must be an array".to_string()))?;
                if rule_arr.len() < 2 {
                    continue;
                }
                
                let pattern_str = rule_arr[0].as_str().ok_or_else(|| ParseError::InvalidFormat("Rule pattern must be a string".to_string()))?;
                let reassembly_arr = rule_arr[1].as_array().ok_or_else(|| ParseError::InvalidFormat("Rule reassembly must be an array".to_string()))?;
                
                let mut reassembly = Vec::new();
                for r in reassembly_arr {
                    if let Some(s) = r.as_str() {
                        reassembly.push(s.to_string());
                    }
                }
                
                let (is_memory_rule, clean_pattern_str) = if pattern_str.starts_with('$') {
                    (true, pattern_str[1..].trim())
                } else {
                    (false, pattern_str)
                };
                
                // Normalize pattern: add spaces around *
                let normalized_pattern = clean_pattern_str.replace('*', " * ");
                let pattern = normalized_pattern.split_whitespace().map(|s| s.to_string()).collect();
                
                rules.push(Rule {
                    pattern,
                    reassembly,
                    is_memory_rule,
                    goto: None,
                });
            }
            
            keywords.insert(name.clone(), Keyword {
                name,
                rank,
                rules,
            });
        }
        
        Ok(keywords)
    }
}
