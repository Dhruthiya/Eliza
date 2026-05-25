# What Is Missing: The Path to a Full Reconstruction

While the provided JavaScript files are a great asset, they are a *port*, not the original. To achieve a truly authentic reconstruction, the following aspects, which define the **exact execution semantics**, need to be formally defined by studying the recommended historical sources:

*   **Wildcard Matching:** Is the `*` wildcard "greedy"? How does it behave with multiple wildcards? Can it match an empty string?
*   **Capture Indexing:** How are capture groups `(n)` numbered, especially with complex patterns involving synonyms?
*   **Response Selection:** When a rule has multiple possible responses, is the selection random, cyclic, or something else? The `elizabot.js` engine has a flag to switch between random and sequential, but the original's exact behavior needs to be confirmed.
*   **Memory System:** What were the exact rules for the memory queue (size, retrieval policy, etc.)?
*   **Formal Grammar:** The current rules are informal. A full reconstruction would require a formal grammar for the ELIZA DSL (`*`, `@`, `()`, `goto`, `$`).

# Recommended Next Steps

The provided documentation gives a clear research order to fill in these missing pieces:

1.  **Start with Weizenbaum's 1966 Paper:** This is the "bible" for the ELIZA architecture and will answer most of the questions about the intended semantics.
2.  **Find the Original DOCTOR Script:** This will provide the canonical set of rules, which may have been simplified or altered in the JavaScript port.
3.  **Analyze the `elizabot.js` Engine:** This provides a working model of the runtime semantics.
4.  **Study Norvig's Lisp ELIZA:** This will provide a clean, well-documented reference implementation to compare against.
5.  **Examine other Lisp Ports:** These are more likely to preserve the original symbolic pattern matching behavior than modern regex-based ports.

By following this path, the project can move from having a good *port* of ELIZA to having a truly accurate, language-independent, and historically faithful *reconstruction* of the original program.