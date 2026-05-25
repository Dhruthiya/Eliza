# ELIZA Wildcard Handling: A Step-by-Step Implementation Guide

This document provides a detailed, unambiguous guide for implementing the wildcard matching, decomposition, and reassembly logic of the original ELIZA program, based on Joseph Weizenbaum's 1966 paper. The goal is to provide a clear algorithm that can be directly translated into code.

This process differs significantly from modern, purely regex-based chatbot engines. The key distinction is that ELIZA's logic creates a numbered list of components from the *entire* matched sentence—including keywords—not just the parts matched by wildcards.

---

## 1. Core Data Structures

Before outlining the algorithm, it's essential to understand the data structures involved.

### Decomposition Rule

A decomposition rule is a template for matching against user input. It should be represented as a list of tokens.

**Example:** The rule `(0 YOU 1 ME)` would be parsed into a list of tokens: `['0', 'YOU', '1', 'ME']`.

*   **String Tokens (e.g., `'YOU'`):** Represent literal keywords that must be matched exactly.
*   **Wildcard Tokens:**
    *   `'0'`: An indefinite wildcard, matching zero or more words.
    *   `'n'` (where n is a non-zero integer): A fixed-length wildcard, matching exactly `n` words.

> **A Note on Historical Accuracy:** While this guide includes a fixed-length `'n'` wildcard for modern implementation clarity, Weizenbaum's original 1966 paper only specified the `'0'` (zero or more words) wildcard. The concept of matching an exact number of words was handled differently in the original Lisp/SLIP implementation. The `'n'` wildcard should be seen as a functional enhancement that captures the spirit of the original's capabilities in a more modern, readable format.

### Reassembly Rule

A reassembly rule is a string template used to generate ELIZA's response. It can contain placeholders that refer to components captured during decomposition.

**Example:** `(What makes you think I am (4))`

*   **Placeholders `(n)`:** `(4)` refers to the 4th component captured during the decomposition process.

### Post-Transformation Map (Pronoun Swapping)

This is a dictionary or hash map that defines word-for-word substitutions to be performed on captured components. This is critical for changing the conversational perspective.

**Example (`elizaPosts` from `elizadata.js`):**
```javascript
{
  "am": "are",
  "your": "my",
  "me": "you",
  "myself": "yourself",
  "yourself": "myself",
  "i": "you",
  "you": "I", // Note the capitalization for "I"
  "my": "your",
  "i'm": "you are"
}
```

---

## 2. The Decomposition Algorithm (Matching and Componentization)

This algorithm takes an input sentence and a decomposition rule and returns a numbered list of matched components if successful. It is best implemented using a recursive, backtracking approach to handle the indefinite `'0'` wildcard.

### Step-by-Step Logic

1.  **Initialization:**
    *   Start with the input sentence as a list of words (e.g., `['i', 'are', 'my', 'own', 'doctor']`).
    *   Start with the decomposition rule as a list of tokens (e.g., `['0', 'i', 'are', '0']`).

2.  **Recursive Matching Function:**
    Use a recursive helper function, e.g., `_match_recursive(sentence_words, rule_tokens, captured_components)`.

3.  **Base Cases (Termination Conditions):**
    *   **Successful Match:** If both `sentence_words` and `rule_tokens` are empty, the entire rule has successfully matched. Return the `captured_components`.
    *   **Failure:** If one list is empty and the other is not (and the non-empty rule list contains more than just `'0'` wildcards), the match fails. Return `null`.

4.  **Process the First Token in the Rule:**
    Let `token = rule_tokens[0]`.

    *   **If `token` is a Keyword (e.g., `'are'`):**
        a. Check if `sentence_words[0]` matches the `token`.
        b. **If it matches, add the `token` itself (from the rule) to the `captured_components` list.** This is a critical step.
        c. Make a recursive call with the rest of the sentence (`sentence_words[1:]`) and the rest of the rule (`rule_tokens[1:]`).
        d. If it does not match, this path fails. Return `null`.

    *   **If `token` is a Fixed-Length Wildcard `n`:**
        a. Check if the sentence has at least `n` words. If not, fail.
        b. Take the first `n` words from the sentence and join them into a single string. This is your component.
        c. Add the component to the `captured_components` list.
        d. Make a recursive call with the rest of the sentence (`sentence_words[n:]`) and the rest of the rule (`rule_tokens[1:]`).

    *   **If `token` is an Indefinite Wildcard `'0'` (Backtracking Logic):**
        a. Iterate with a loop variable `i` from `0` to `len(sentence_words)`. `i` represents the number of words to be consumed by the `'0'` wildcard.
        b. For each `i`:
            i.  Create the component for this path: `component = join(sentence_words[0:i])`.
            ii. Create a temporary list of captured components for this path: `new_components = captured_components + [component]`.
            iii. Make a recursive call: `result = _match_recursive(sentence_words[i:], rule_tokens[1:], new_components)`.
            iv. **If the recursive call returns a successful match (`result` is not `null`), then a valid path has been found. Immediately return this `result`.**
        c. If the loop finishes without finding a match, this path has failed. Return `null`.

---

## 3. The Component Transformation Algorithm

**This is a mandatory step between decomposition and reassembly.** Before generating a response, the captured components must be transformed to switch the conversational perspective.

1.  **Input:** The list of `captured_components` from the successful decomposition and the `Post-Transformation Map`.
2.  **Initialize:** Create a new empty list, `transformed_components`.
3.  **Iterate and Transform:** For each `component_string` in the `captured_components` list:
    a. Split the `component_string` into a list of words.
    b. Create a new list for the transformed words.
    c. For each `word` in the component, check if it exists as a key in the `Post-Transformation Map`.
    d. If it exists, add the map's value (e.g., `map['my']` -> `"your"`) to the new word list.
    e. If it does not exist, add the original `word`.
    f. Join the new word list back into a single string and add it to `transformed_components`.
4.  **Output:** The `transformed_components` list.

---

## 4. The Reassembly Algorithm

This process uses the *transformed* components to generate the final response.

1.  **Input:** A reassembly rule string (e.g., `"What makes you think I am (4)"`) and the `transformed_components` list.
2.  **Find and Replace Placeholders:** For each placeholder `(n)` found in the rule string:
    a. Parse the number `n`.
    b. Retrieve the component at index `n-1` from the `transformed_components` list.
    c. Replace the placeholder `(n)` with the retrieved component text.
3.  **Output:** The final, assembled string is ELIZA's response.

---

## 5. A Complete Walkthrough (Revised)

*   **Input Sentence:** `"I are my own doctor"` -> `['i', 'are', 'my', 'own', 'doctor']`
*   **Decomposition Rule:** `(0 I are 0)` -> `['0', 'i', 'are', '0']`
*   **Reassembly Rule:** `What makes you think I am (4)`

### 1. Decomposition Trace:

The decomposition algorithm runs as described previously. The backtracking logic of the first `'0'` wildcard finds that it must match an empty string for the subsequent `'i'` and `'are'` tokens to match the sentence. The second `'0'` then matches the rest of the sentence.

*   **Final `captured_components`:** `['', 'i', 'are', 'my own doctor']`

### 2. Transformation Trace:

The system now applies the `Post-Transformation Map` to the `captured_components`.

*   Component 1: `''` -> `''`
*   Component 2: `'i'` -> The map contains `"i": "you"`. The component becomes `'you'`.
*   Component 3: `'are'` -> The map contains `"are": "am"`. The component becomes `'am'`.
*   Component 4: `'my own doctor'` -> This string is split into `['my', 'own', 'doctor']`.
    *   `'my'` is in the map (`"my": "your"`).
    *   `'own'` is not.
    *   `'doctor'` is not.
    *   The words are reassembled into `'your own doctor'`.
*   **Final `transformed_components`:** `['', 'you', 'am', 'your own doctor']`

### 3. Reassembly Trace:

1.  **Input:** Rule `"What makes you think I am (4)"` and the `transformed_components` list.
2.  Find placeholder `(4)`.
3.  Get the component at index `4-1=3`, which is `"your own doctor"`.
4.  Replace `(4)` with `"your own doctor"`.
5.  **Final Output:** `"What makes you think I am your own doctor"`