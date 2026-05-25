# ELIZA Wildcard Handling: A Step-by-Step Implementation Guide

This document provides a detailed, unambiguous guide for implementing the wildcard matching, decomposition, and reassembly logic of the original ELIZA program, based on Joseph Weizenbaum's 1966 paper. The goal is to provide a clear algorithm that can be directly translated into code.

This process differs significantly from modern, purely regex-based chatbot engines. The key distinction is that ELIZA's logic creates a numbered list of components from the *entire* matched sentence, including keywords, not just the parts matched by wildcards.

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

### Reassembly Rule

A reassembly rule is a string template used to generate ELIZA's response. It can contain placeholders that refer to components captured during decomposition.

**Example:** `(What makes you think I am 4)`

*   **Placeholders `(n)`:** `(4)` refers to the 4th component captured during the decomposition process.

---

## 2. The Decomposition Algorithm (Matching and Componentization)

This is the core of the process. The goal of this algorithm is to take an input sentence (as a list of words) and a decomposition rule (as a list of tokens) and return a numbered list of matched components if the match is successful.

This algorithm is best implemented using a recursive, backtracking approach to handle the greedy nature of the indefinite `'0'` wildcard.

### Function Signature

A possible function signature for the core matching logic could be:

`match(sentence_words, rule_tokens) -> returns [list_of_components] or null`

### Step-by-Step Logic

1.  **Initialization:**
    *   Start with the full input sentence as a list of words (e.g., `['i', 'are', 'very', 'helpful']`).
    *   Start with the full decomposition rule as a list of tokens (e.g., `['0', 'i', 'are', '0']`).
    *   Initialize an empty list to store the captured components.

2.  **Recursive Matching Function:**
    Create a recursive helper function, e.g., `_match_recursive(sentence_words, rule_tokens, captured_components)`.

3.  **Base Cases (Termination Conditions):**
    *   **Successful Match:** If both `sentence_words` and `rule_tokens` are empty, it means the entire rule has successfully matched the entire sentence. Return the `captured_components`.
    *   **Failure (Rule has tokens, Sentence does not):** If `rule_tokens` is not empty but `sentence_words` is, the match has failed (unless the remaining rule tokens are all `'0'`). Return `null`.
    *   **Failure (Sentence has words, Rule does not):** If `sentence_words` is not empty but `rule_tokens` is, the match has failed. Return `null`.

4.  **Process the First Token in the Rule:**
    Let `token = rule_tokens[0]`.

    *   **If `token` is a Keyword (e.g., `'are'`):**
        a. Check if `sentence_words[0]` matches the `token`.
        b. If it matches, add the word to the `captured_components` list.
        c. Make a recursive call with the rest of the sentence and the rest of the rule: `_match_recursive(sentence_words[1:], rule_tokens[1:], captured_components)`.
        d. If it does not match, this path fails. Return `null`.

    *   **If `token` is a Fixed-Length Wildcard `n` (e.g., `'1'`):**
        a. Check if the sentence has at least `n` words. If not, this path fails. Return `null`.
        b. Take the first `n` words from the sentence. This is your next component.
        c. Add the component (as a single string, e.g., `"word1 word2"`) to the `captured_components` list.
        d. Make a recursive call with the rest of the sentence (`sentence_words[n:]`) and the rest of the rule (`rule_tokens[1:]`).

    *   **If `token` is an Indefinite Wildcard `'0'`:**
        This is the most complex case and requires backtracking.
        a. Iterate from `i = 0` to `len(sentence_words)`. The variable `i` represents the number of words to be consumed by the `'0'` wildcard.
        b. For each `i`:
            i.  Create the component for this iteration: `component = sentence_words[0:i]`.
            ii. Create a new list of captured components for this path: `new_components = captured_components + [component]`.
            iii. Make a recursive call with the rest of the sentence and the rest of the rule: `result = _match_recursive(sentence_words[i:], rule_tokens[1:], new_components)`.
            iv. **If the recursive call returns a successful match (`result` is not `null`), then we have found a valid path. Immediately return this `result`.**
        c. If the loop finishes without finding a successful match, it means this path has failed. Return `null`.

---

## 3. The Reassembly Algorithm

This process is straightforward once you have the list of components from a successful decomposition.

1.  **Input:** A reassembly rule string (e.g., `"What makes you think I am (4)"`) and the list of components (e.g., `['', 'I', 'are', 'very helpful']`).
2.  **Find Placeholders:** Use a simple regex or string search to find all occurrences of the placeholder pattern `(n)`.
3.  **Substitute:** For each placeholder found:
    a. Parse the number `n` from the placeholder.
    b. Retrieve the component at index `n-1` from the list of components (since the components are 1-indexed in the rule but the list is likely 0-indexed).
    c. Replace the placeholder `(n)` with the retrieved component text.
4.  **Output:** The final, assembled string is ELIZA's response.

---

## 4. A Complete Walkthrough

Let's trace the full process with an example from the paper.

*   **Input Sentence:** `"I are very helpful"` -> `['i', 'are', 'very', 'helpful']`
*   **Decomposition Rule:** `(0 I are 0)` -> `['0', 'i', 'are', '0']`
*   **Reassembly Rule:** `What makes you think I am (4)`

### Decomposition Trace:

1.  `_match_recursive(['i', 'are', 'very', 'helpful'], ['0', 'i', 'are', '0'], [])`
2.  First token is `'0'`. The algorithm will try to match it with `i` words, from 0 to 4.
    *   **Try `i=0`:** The `'0'` matches `''` (empty string).
        *   `captured_components` is now `['']`.
        *   Recursive call: `_match_recursive(['i', 'are', 'very', 'helpful'], ['i', 'are', '0'], [''])`.
3.  The next token is `'i'`. It matches the first word of the sentence.
    *   `captured_components` is now `['', 'i']`.
    *   Recursive call: `_match_recursive(['are', 'very', 'helpful'], ['are', '0'], ['', 'i'])`.
4.  The next token is `'are'`. It matches the first word of the remaining sentence.
    *   `captured_components` is now `['', 'i', 'are']`.
    *   Recursive call: `_match_recursive(['very', 'helpful'], ['0'], ['', 'i', 'are'])`.
5.  The next token is `'0'`. There is only one token left in the rule. This `'0'` must match the rest of the sentence.
    *   The `'0'` matches `'very helpful'`.
    *   `captured_components` is now `['', 'i', 'are', 'very helpful']`.
    *   Recursive call: `_match_recursive([], [], ['', 'i', 'are', 'very helpful'])`.
6.  **Base Case:** Both the sentence and rule lists are empty. The match is successful. The function returns the final component list: `['', 'i', 'are', 'very helpful']`.

### Reassembly Trace:

1.  **Input:** Rule `"What makes you think I am (4)"` and Components `['', 'i', 'are', 'very helpful']`.
2.  Find placeholder `(4)`.
3.  Get the component at index `4-1=3`, which is `"very helpful"`.
4.  Replace `(4)` with `"very helpful"`.
5.  **Final Output:** `"What makes you think I am very helpful"`
