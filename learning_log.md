# ELIZA Development Learning Log

## [2026-05-25] - Project Initialization & Research
### Tasks Completed
- **Team Formation:** Assembled a team of 6 members to build three implementations of ELIZA in **Elixir**, **Go**, and **Crystal**.
- **Resource Gathering:** Searching for existing documentation, research papers, and original scripts to understand the ELIZA/DOCTOR logic.
- **Architecture Design:** Commenced drafting the architecture for building the bot from scratch.

### Technical Insights
- **Processing Pipeline:** Defined the 7-step lifecycle for processing user input:
    1. **Normalize:** Lowercase, punctuation removal, and PRE-transformations (e.g., "I'm" -> "I am").
    2. **Scan for Keywords:** Search input for keywords sorted by precedence/rank (e.g., "computer" rank 50 vs. "i" rank 0).
    3. **Match Transformation Rules:** Match decomposition patterns against the input using greedy wildcards.
    4. **Select Reassembly Rule:** Choose a response template associated with the matched pattern.
    5. **Substitute Captures:** Fill the reassembly template with captured fragments from the input.
    6. **Post-Transformation:** Apply reflections (e.g., "your" -> "my", "you" -> "I").
    7. **Output:** Deliver the final string to the user.
- **Wildcard Logic:** Wildcards are **greedy**, meaning they attempt to match the longest possible string.
    - *Example:* Pattern `(* I * YOU *)` against "I think I love you very much" captures `(3) = "think I love"` rather than stopping at the first "I".
- **Concept:** ELIZA creates an illusion of intelligence (the "ELIZA effect") through simple pattern matching and substitution rather than genuine semantic understanding.

### Next Steps
- Finalize the unified data format for the Eliza "scripts" (e.g., JSON files in `data/`).
- Begin the "skeleton" implementation in all three languages.
