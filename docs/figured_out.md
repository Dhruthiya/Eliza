# Core Components of the ELIZA Implementation

The provided JavaScript implementation is split into two main parts:

1.  **The Engine (`elizabot.js`):** This is the "brain" of the chatbot. It is a general-purpose engine that takes user input, processes it according to a set of rules, and generates a response. It is not hardcoded to a specific personality. Its logic includes:
    *   Input normalization (lowercase, punctuation handling).
    *   Keyword searching and ranking.
    *   Pattern matching using regular expressions.
    *   Transforming and reassembling responses.
    *   Managing conversational memory.
    *   Handling pronoun reflection.

2.  **The Dataset (`elizadata.js`):** This file contains the "personality" of the chatbot, specifically the **DOCTOR** script that simulates a Rogerian psychotherapist. It defines the entire knowledge base for the conversation, including:
    *   **Keywords and Ranks:** A list of keywords to look for in the user's input, each with a priority (rank). For example, `computer` has a high rank (50), making it a dominant topic.
    *   **Decomposition Rules:** Patterns associated with each keyword that are used to break down the user's sentence. For example, `"* i remember *"` is a pattern for the keyword `remember`.
    *   **Reassembly Templates:** A set of responses for each decomposition rule. The engine uses these templates to construct ELIZA's reply, often inserting parts of the user's sentence (capture groups) into the template.
    *   **Synonyms:** A list of words that are treated as equivalent (e.g., `belief` can be `feel`, `think`, `believe`, or `wish`).
    *   **Pre/Post Transformations:** Rules for normalizing input (e.g., `don't` -> `dont`) and for reflecting pronouns in the response (e.g., `my` -> `your`).

# Execution Flow: How the Engine Works

The `elizabot.js` engine follows a clear, multi-step process to generate a response, which is the core of the ELIZA architecture:

1.  **Input:** The user provides a sentence.
2.  **Normalization:** The engine cleans the input by converting it to lowercase, handling punctuation, and applying pre-transformations (e.g., `i'm` becomes `i am`).
3.  **Keyword Detection:** The engine scans the input for keywords defined in `elizaKeywords`, starting with the highest-ranked keyword.
4.  **Decomposition (Pattern Matching):** Once the highest-ranking keyword is found, the engine tries to match the user's sentence against the decomposition patterns associated with that keyword.
5.  **Reassembly (Response Generation):** If a pattern matches, the engine selects one of the corresponding reassembly templates.
6.  **Capture Group Injection:** The engine takes the parts of the user's sentence that matched wildcards (`*`) in the decomposition pattern and inserts them into the reassembly template where `(n)` placeholders are found.
7.  **Pronoun Reflection:** The engine applies post-transformation rules to the captured parts to switch the perspective (e.g., `I` becomes `you`, `my` becomes `your`).
8.  **Memory:** If a rule is marked with a `$` (like `"* my *"`), the generated response is not immediately returned but is stored in a short-term memory queue. If no other rules match in a later turn, a response is retrieved from this memory.
9.  **`goto` Redirection:** Some rules can redirect the engine to another keyword's rules, allowing for conversational logic to be reused.
10. **Fallback:** If no keywords or patterns match, the engine uses the `xnone` keyword to provide a generic, non-committal response (e.g., "Please go on.").
11. **Output:** The final, assembled response is returned to the user.