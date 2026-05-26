use eliza::decomposer::Decomposer;
use std::collections::HashMap;

#[test]
fn test_wildcard_capture() {
    let sentence: Vec<String> = "I are my own doctor".split_whitespace().map(|s| s.to_string()).collect();
    let pattern: Vec<String> = "* i are *".split_whitespace().map(|s| s.to_string()).collect();
    let synons = HashMap::new();
    
    let result = Decomposer::decompose(&sentence, &pattern, &synons).expect("Should match");
    
    // components should be ['', 'my own doctor']
    assert_eq!(result.len(), 2);
    assert_eq!(result[0], "");
    assert_eq!(result[1], "my own doctor");
}

#[test]
fn test_synon_capture() {
    let sentence: Vec<String> = "I feel happy".split_whitespace().map(|s| s.to_string()).collect();
    let pattern: Vec<String> = "* I @belief *".split_whitespace().map(|s| s.to_string()).collect();
    let mut synons = HashMap::new();
    synons.insert("belief".to_string(), vec!["feel".to_string(), "think".to_string()]);
    
    let result = Decomposer::decompose(&sentence, &pattern, &synons).expect("Should match");
    
    // components: [index 1 (*), index 2 (@belief), index 3 (*)]
    // Wait, "I" is a literal keyword, so it's not captured.
    // Indexing:
    // 1: * -> ""
    // (I is literal)
    // 2: @belief -> "feel"
    // 3: * -> "happy"
    assert_eq!(result.len(), 3);
    assert_eq!(result[0], "");
    assert_eq!(result[1], "feel");
    assert_eq!(result[2], "happy");
}
