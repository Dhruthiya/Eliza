# What Is Still Missing: Historical Accuracy

The primary unknown is no longer *how* the system works, but rather the set of subtle differences between the current JavaScript implementation (`elizabot.js`) and Joseph Weizenbaum's original 1966 Lisp/SLIP implementation.

While we have a robust, working model, achieving a truly faithful reconstruction requires clarifying the exact historical semantics to ensure our version is not just a port, but a true recreation.

### Specific Historical Ambiguities

1.  **Original Wildcard and Decomposition Logic:**
    *   The logic described in our `implementation_guide.md` is based on a careful reading of the 1966 paper. However, a code-level comparison with the original Lisp/SLIP source code (if it can be found) is the only way to be 100% certain about the nuances of the backtracking algorithm and componentization.

2.  **Original Response Selection Policy:**
    *   The `elizabot.js` implementation provides both random and cyclic selection. Was the original implementation truly random, or did it use a simpler pseudo-random generator or a purely cyclic method?

3.  **Original Memory System:**
    *   Were the memory queue size (20 in `elizabot.js`) and the FIFO retrieval policy identical to the original implementation?

### Recommended Next Steps (Unchanged)

The path to resolving these final ambiguities remains the same. The focus is on comparing our current understanding against historical sources.

1.  **Deep-Dive into Weizenbaum's 1966 Paper:** Continue to analyze the paper for any further clues about the original implementation's specific algorithms.
2.  **Find and Analyze the Original DOCTOR Script:** This is crucial to confirm the canonical rules and data structures, which may have been altered in the JS port.
3.  **Study Norvig's Lisp ELIZA:** Norvig's clean, modern Lisp implementation is an excellent reference for a well-documented interpretation of the original logic.
4.  **Examine other classic Lisp Ports:** If the original source is unavailable, other early Lisp implementations are the most likely to preserve the original's symbolic, list-based processing semantics.