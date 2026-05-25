# ELIZA - Implementation Plan (Version 1.0)

This document outlines the implementation plan for creating a foundational, "historically-inspired" ELIZA engine. The primary goal of Version 1.0 is to build a robust core that correctly implements the essential ELIZA logic and can be tested against a known script.

---

## 1. Goal for Version 1.0

**To create a functional ELIZA engine that correctly implements the core decomposition/reassembly logic and can accurately reproduce the classic DOCTOR script conversation.**

This version will prioritize a clean, well-structured implementation based on our understanding from the Weizenbaum paper and the `implementation_guide.md`, rather than a 100% historically perfect replica of the original Lisp code.

---

## 2. Key Milestones & Phases

The project will be broken down into five distinct phases.

### Phase 1: Project Setup & Data Modeling

This phase focuses on creating the foundational structures for the project.

*   **Task 1.1: Choose Language & Set Up Project:**
    *   **Language:** Go (Golang) is recommended for its strong standard library, efficiency, and suitability for building parsers and command-line tools.
    *   **Action:** Initialize a new Go project (`go mod init`).

*   **Task 1.2: Define Canonical Data Structures:**
    *   **Goal:** Create language-native structs that represent the ELIZA script data in a clean, language-independent way.
    *   **Action:** Define the following Go structs:
        ```go
        // Represents a single decomposition rule and its reassembly templates.
        type Rule struct {
            Pattern      []string // e.g., ["*", "i", "remember", "*"]
            Reassembly   []string // List of possible responses
            IsMemoryRule bool     // True if pattern starts with '$'
        }

        // Represents a keyword and its associated rules.
        type Keyword struct {
            Name       string
            Rank       int
            Rules      []Rule
        }

        // Represents the entire ELIZA script.
        type Script struct {
            Initials       []string
            Finals         []string
            Quits          []string
            Pres           map[string]string // Pre-transformation map
            Posts          map[string]string // Post-transformation map
            Synons         map[string][]string
            Keywords       map[string]Keyword
            PostTransforms [][2]string // Final regex-based cleanup
        }
        ```

*   **Task 1.3: Implement a Script Parser:**
    *   **Goal:** Create a parser that can read the `elizadata.js` file (or a JSON-formatted version of it) and load its contents into the Go structs defined above.
    *   **Action:** Write a Go package to handle the parsing and validation of the script file.

### Phase 2: The Decomposition Engine

This is the most complex phase, focusing on the core pattern-matching logic.

*   **Task 2.1: Implement the Wildcard Matching Algorithm:**
    *   **Goal:** Implement the recursive, backtracking algorithm detailed in `docs/handling_problems/wildcard/implementation_guide.md`.
    *   **Action:** Create a function that takes a sentence (as `[]string`) and a rule pattern (as `[]string`) and returns a list of captured components (`[]string`) or `nil` if the match fails. This function must correctly handle the `'0'` (indefinite) wildcard.

*   **Task 2.2: Implement Componentization Logic:**
    *   **Goal:** Ensure that the matching algorithm correctly captures all parts of the sentence as components, including keywords, as specified in the implementation guide.
    *   **Action:** The output of the matching algorithm should be a list like `['', 'i', 'are', 'my own doctor']`, which can be passed to the next phase.

### Phase 3: Transformation & Reassembly

This phase focuses on constructing the response from the decomposed parts.

*   **Task 3.1: Implement Component Transformation:**
    *   **Goal:** Implement the pronoun-swapping logic.
    *   **Action:** Create a function that takes the list of captured components and the `Posts` map from the script, and returns a new list of transformed components.

*   **Task 3.2: Implement Reassembly:**
    *   **Goal:** Substitute the transformed components into the chosen reassembly template.
    *   **Action:** Create a function that takes a reassembly string (e.g., `"What makes you think I am (4)"`) and the list of transformed components, and returns the final response string.

### Phase 4: The Main Engine Loop

This phase ties all the components together into a functioning engine.

*   **Task 4.1: Implement the Main `Transform` Function:**
    *   **Goal:** Create the main entry point for the engine that processes user input.
    *   **Action:** This function will orchestrate the entire process:
        1.  Normalize input (using the `Pres` map).
        2.  Identify the highest-ranking keyword.
        3.  Iterate through the keyword's rules, calling the Decomposition engine.
        4.  If a match is found, call the Transformation and Reassembly engines.
        5.  Return the final response.

*   **Task 4.2: Implement `goto`, Memory, and Response Selection:**
    *   **Goal:** Add the remaining core ELIZA features.
    *   **Action:**
        *   **Response Selection:** Implement a cyclic (non-random) selection policy for Version 1.0 to ensure deterministic testing.
        *   **Memory (`$`):** Implement the memory queue (e.g., a simple slice) for storing and retrieving memories when no other rule matches.
        *   **`goto`:** Implement the logic to redirect rule processing to a different keyword.

### Phase 5: Interface and Testing

*   **Task 5.1: Create a Command-Line Interface (CLI):**
    *   **Goal:** Create a simple way to interact with the engine.
    *   **Action:** Build a `main.go` file that creates a `Read-Eval-Print Loop` (REPL), allowing a user to "chat" with ELIZA from the terminal.

*   **Task 5.2: Create a "Golden Transcript" Test:**
    *   **Goal:** Verify the implementation's correctness against a known standard.
    *   **Action:** Write an automated test that feeds the input from Weizenbaum's original conversation (found in `eliza_test.html`) into the engine and asserts that the output exactly matches the original.

---

## 3. Definition of Done for Version 1.0

Version 1.0 will be considered complete when:

*   The engine can successfully parse and load the `elizadata.js` script into the canonical Go data structures.
*   The engine's core logic (Decomposition, Transformation, Reassembly) is fully implemented as per the `implementation_guide.md`.
*   The engine successfully and repeatedly passes the "Golden Transcript" test, proving it can accurately reproduce the classic DOCTOR conversation.
*   A user can have a basic, interactive conversation with the DOCTOR personality via the CLI.

---

## 4. Outline for Future Versions (v2.0 and beyond)

This foundational implementation will enable the following future enhancements:

*   **Historical Accuracy:** Conduct deeper research into the original Lisp source code to refine the engine's semantics to be a 100% faithful replica.
*   **Engine Abstraction:** Formally separate the engine from the script, allowing different "personality" files to be loaded at runtime.
*   **Concurrency:** Refactor the engine to handle multiple users simultaneously.
*   **Extended DSL:** Add more advanced features to the script DSL, such as conditional logic or state variables.
