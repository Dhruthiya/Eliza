use crate::decomposer::Decomposer;
use crate::script::{Keyword, Script};
use crate::state::ConversationState;
use crate::transformer::Transformer;
use regex::Regex;

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

    pub fn transform(&mut self, input: &str) -> String {
        let normalized = self.normalize_input(input);
        let words: Vec<String> = normalized
            .split_whitespace()
            .map(|s| s.to_string())
            .collect();

        if words.is_empty() {
            return "Please say something.".to_string();
        }

        if self.is_quit(&words) {
            return self.get_final();
        }

        if let Some(response) = Self::find_response(&words, &self.script, &mut self.state) {
            return response;
        }

        if let Some(memory) = self.state.get_memory() {
            return memory;
        }

        self.get_fallback_response()
    }

    fn normalize_input(&self, input: &str) -> String {
        let mut text = input.to_lowercase();
        // Remove non-alphanumeric characters EXCEPT apostrophe
        let re = Regex::new(r"[^a-z0-9'\s]").unwrap();
        text = re.replace_all(&text, " ").to_string();

        let mut words: Vec<String> = text.split_whitespace().map(|s| s.to_string()).collect();
        for word in words.iter_mut() {
            if let Some(to) = self.script.pres.get(word) {
                *word = to.clone();
            }
        }
        words.join(" ")
    }

    fn is_quit(&self, words: &[String]) -> bool {
        words.iter().any(|w| self.script.quits.contains(w))
    }

    fn find_response(words: &[String], script: &Script, state: &mut ConversationState) -> Option<String> {
        let sorted_keywords = script.keywords_by_rank();
        for keyword in sorted_keywords {
            if words.contains(&keyword.name) || keyword.name == "xnone" {
                if let Some(response) = Self::try_keyword_rules(words, keyword, script, state) {
                    return Some(response);
                }
            }
        }
        None
    }

    fn try_keyword_rules(words: &[String], keyword: &Keyword, script: &Script, state: &mut ConversationState) -> Option<String> {
        for (idx, rule) in keyword.rules.iter().enumerate() {
            if let Some(components) = Decomposer::decompose(words, &rule.pattern, &script.synons) {
                let transformed = Transformer::transform_components(&components, &script.posts);
                let reassembly_list = &rule.reassembly;
                if reassembly_list.is_empty() {
                    continue;
                }
                
                let resp_idx = state.get_next_response_index(&keyword.name, idx, reassembly_list.len());
                let template = &reassembly_list[resp_idx];
                
                if template.starts_with("goto ") {
                    let goto_name = template.trim_start_matches("goto ").trim();
                    if let Some(target_kw) = script.get_keyword(goto_name) {
                        if let Some(resp) = Self::try_keyword_rules(words, target_kw, script, state) {
                            return Some(resp);
                        }
                    }
                    continue;
                }
                
                let response = Transformer::reassemble(template, &transformed);
                if rule.is_memory_rule {
                    state.add_memory(response.clone());
                    continue;
                }
                return Some(response);
            }
        }
        None
    }

    fn get_fallback_response(&mut self) -> String {
        if let Some(xnone) = self.script.get_keyword("xnone") {
            if let Some(resp) = Self::try_keyword_rules(&[], xnone, &self.script, &mut self.state) {
                return resp;
            }
        }
        "I am not sure I understand you fully.".to_string()
    }

    fn get_final(&self) -> String {
        self.script.finals.first().cloned().unwrap_or_else(|| "Goodbye.".to_string())
    }

    pub fn get_initial(&self) -> String {
        self.script.initials.first().cloned().unwrap_or_else(|| "Hello.".to_string())
    }
}
