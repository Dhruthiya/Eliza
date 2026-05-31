use std::collections::HashMap;

pub struct Decomposer;

impl Decomposer {
    pub fn decompose(
        sentence: &[String],
        pattern: &[String],
        synons: &HashMap<String, Vec<String>>,
    ) -> Option<Vec<String>> {
        Self::match_recursive(sentence, pattern, Vec::new(), synons)
    }

    fn match_recursive(
        sentence: &[String],
        pattern: &[String],
        mut components: Vec<String>,
        synons: &HashMap<String, Vec<String>>,
    ) -> Option<Vec<String>> {
        if sentence.is_empty() && pattern.is_empty() {
            return Some(components);
        }

        if pattern.is_empty() {
            return None;
        }

        if sentence.is_empty() {
            if pattern.iter().all(|t| t == "*" || t == "0") {
                for _ in pattern {
                    components.push(String::new());
                }
                return Some(components);
            }
            return None;
        }

        let token = &pattern[0];

        if token == "*" || token == "0" {
            for i in 0..=sentence.len() {
                let component = if i == 0 {
                    String::new()
                } else {
                    sentence[..i].join(" ")
                };

                let mut new_components = components.clone();
                new_components.push(component);

                if let Some(result) =
                    Self::match_recursive(&sentence[i..], &pattern[1..], new_components, synons)
                {
                    return Some(result);
                }
            }
            return None;
        }

        if let Ok(n) = token.parse::<usize>() {
            if n > 0 && sentence.len() >= n {
                let component = sentence[..n].join(" ");
                components.push(component);
                return Self::match_recursive(&sentence[n..], &pattern[1..], components, synons);
            }
            return None;
        }

        if token.starts_with('@') {
            let class_name = &token[1..];
            if let Some(synonyms) = synons.get(class_name) {
                let word = &sentence[0];
                if synonyms.iter().any(|s| s.eq_ignore_ascii_case(word)) || class_name.eq_ignore_ascii_case(word) {
                    components.push(word.clone());
                    return Self::match_recursive(&sentence[1..], &pattern[1..], components, synons);
                }
            }
            return None;
        }

        // Literal keyword - match but DO NOT push to components
        if sentence[0].eq_ignore_ascii_case(token) {
            return Self::match_recursive(&sentence[1..], &pattern[1..], components, synons);
        }

        None
    }
}
