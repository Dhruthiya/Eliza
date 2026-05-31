# ELIZA Engine Architecture Overview

This document provides a high-level overview of the ELIZA engine's architecture, which is shared across our multiple implementations. The goal of this architecture is to remain faithful to Weizenbaum's 1966 logic while utilizing modern programming patterns.

## Component Overview

The engine consists of four primary components:

1.  **Script Loader:** Responsible for parsing the JSON data files and building the internal keyword hierarchy.
2.  **Normalization Pipeline:** Cleans and prepares user input for matching.
3.  **Decomposer (Matcher):** The core logic that matches normalized input against patterns.
4.  **Transformer (Reassembler):** Handles template substitution and perspective reflection.

---

## 1. Normalization Pipeline

Before any matching occurs, the raw user input is processed:
- **Lowercase:** All text is converted to lowercase.
- **Punctuation Stripping:** Most punctuation is removed or replaced with spaces to ensure word-based matching.
- **Pre-Transformation:** Words like "don't" are expanded to "do not" based on the `elizaPres.json` dictionary.

---

## 2. The Keyword Scan

The engine does not match against every rule. Instead:
1.  It scans the normalized input for words that exist in the **Keyword List**.
2.  Keywords are sorted by their **Rank** (precedence).
3.  The engine attempts to match the rules of the highest-ranked keyword first.

---

## 3. Decomposition (Pattern Matching)

Decomposition is the process of breaking a sentence into parts based on a pattern.

- **Pattern:** `(* I * YOU *)`
- **Input:** "I think I love you very much"
- **Fragments captured:**
    - `(1)`: "" (empty, before first "I")
    - `(2)`: "think I love" (between "I" and "YOU")
    - `(3)`: "very much" (after "YOU")

**Note:** Our implementation uses **greedy matching**, meaning the `*` will capture the longest possible string that satisfies the rest of the pattern.

---

## 4. Reassembly & Post-Transformation

Once a pattern matches, the engine selects a reassembly rule (template).

- **Template:** "What makes you think (2) me?"
- **Substitution:** "What makes you think **think I love** me?"
- **Post-Transformation:** Before final delivery, captured fragments are reflected using `elizaPosts.json` (e.g., "I" -> "you", "my" -> "your").
- **Final Output:** "What makes you think **think you love** me?"

---

## 5. State Management

The engine maintains a simple state for each conversation session:
- **Response Cycling:** Keeps track of which reassembly rule was used last for a keyword to ensure variety.
- **Memory Queue:** Some rules (like the keyword "MY") store a response in a FIFO queue to be used later if no other keywords match the input.
