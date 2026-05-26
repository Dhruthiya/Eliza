use std::collections::HashMap;
use regex::Regex;

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
        let re = Regex::new(r"\((\d+)\)").unwrap();
        
        re.replace_all(template, |caps: &regex::Captures| {
            let n: usize = caps[1].parse().unwrap_or(0);
            if n > 0 && n <= components.len() {
                components[n - 1].clone()
            } else {
                caps[0].to_string()
            }
        }).to_string()
    }
}
