use eliza::engine::ElizaEngine;
use eliza::parser::ScriptLoader;
use std::path::Path;

#[test]
fn test_golden_transcript() {
    let script_path = Path::new("../data");
    let script = ScriptLoader::load_from_directory(script_path).expect("Failed to load script");
    let mut engine = ElizaEngine::new(script, false);

    // Test cases from Weizenbaum's original conversation
    let test_cases = vec![
        ("Men are all alike.", "IN WHAT WAY"),
        ("They're always bugging us about something or other.", "CAN YOU THINK OF A SPECIFIC EXAMPLE"),
        ("Well, my boyfriend made me come here.", "YOUR BOYFRIEND MADE YOU COME HERE"),
        ("He says I'm depressed much of the time.", "I AM SORRY TO HEAR THAT YOU ARE DEPRESSED"),
        ("It is true. I am unhappy.", "DO YOU THINK COMING HERE WILL HELP YOU NOT TO BE UNHAPPY"),
    ];

    for (input, expected) in test_cases {
        let response = engine.transform(input);
        let normalized_response = response.to_uppercase()
            .replace(|c: char| !c.is_alphanumeric(), " ")
            .split_whitespace()
            .collect::<Vec<_>>()
            .join(" ");
            
        let normalized_expected = expected.to_uppercase()
            .replace(|c: char| !c.is_alphanumeric(), " ")
            .split_whitespace()
            .collect::<Vec<_>>()
            .join(" ");
            
        assert_eq!(
            normalized_response,
            normalized_expected,
            "Failed for input: {}. Got: '{}', Expected: '{}'",
            input, response, expected
        );
    }
}
