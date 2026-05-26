use std::collections::{HashMap, VecDeque};
use rand::seq::SliceRandom;

pub struct ConversationState {
    memory: VecDeque<String>,
    max_memory: usize,
    response_counters: HashMap<String, usize>,
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
    
    pub fn add_memory(&mut self, response: String) {
        if self.memory.len() >= self.max_memory {
            self.memory.pop_front();
        }
        self.memory.push_back(response);
    }
    
    pub fn get_memory(&mut self) -> Option<String> {
        if self.memory.is_empty() {
            return None;
        }

        if self.use_random {
            let mut rng = rand::thread_rng();
            let indices: Vec<usize> = (0..self.memory.len()).collect();
            let idx = *indices.choose(&mut rng).unwrap();
            Some(self.memory.remove(idx).unwrap())
        } else {
            self.memory.pop_front()
        }
    }
    
    pub fn get_next_response_index(&mut self, keyword_name: &str, rule_index: usize, count: usize) -> usize {
        if count == 0 {
            return 0;
        }

        if self.use_random {
            let mut rng = rand::thread_rng();
            let indices: Vec<usize> = (0..count).collect();
            *indices.choose(&mut rng).unwrap_or(&0)
        } else {
            let key = format!("{}:{}", keyword_name, rule_index);
            let counter = self.response_counters.entry(key).or_insert(0);
            let idx = *counter % count;
            *counter += 1;
            idx
        }
    }
}
