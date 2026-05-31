# What We Know: Core Components and Execution Semantics

This document details what has been figured out from the provided `elizabot.js` script and its associated documentation.

## Core Components

The JavaScript implementation is split into two main parts:

1.  **The Engine (`elizabot.js`):** This is the "brain" of the chatbot. It is a general-purpose engine that takes user input, processes it according to a set of rules, and generates a response.
2.  **The Dataset (`elizadata.js`):** This file contains the "personality" of the chatbot, specifically the **DOCTOR** script. It defines the keywords, ranks, decomposition rules, reassembly templates, synonyms, and transformations.

## Detailed Execution Semantics (According to `elizabot.js`)

The `elizabot.js` engine and the `implementation_guide.md` provide clear, implementable logic for the following core semantic questions:

### 1. Capture Indexing and Formal Grammar

A formal grammar for the ELIZA DSL is effectively defined by the combination of the `elizabot.js` parsing logic and the `implementation_guide.md`.

*   **DSL Elements:** The grammar consists of:
    *   `*` or `0`: An indefinite wildcard.
    *   `@synon`: A placeholder for a class of synonymous words.
    *   `$`: A prefix for a rule that flags its output for memory.
    *   `goto`: A command to redirect to another keyword's rules.
    *   `(n)`: A placeholder for the n-th captured component.
*   **Capture Indexing Logic:** The `implementation_guide.md` provides a precise algorithm for how capture groups `(n)` are numbered. It uses a recursive, token-based matching system where **every matched part of the rule (wildcards and keywords) becomes a numbered component.** This provides an unambiguous way to handle complex patterns.

### 2. Response Selection Policy

The logic for selecting a response when a rule has multiple options is explicitly implemented in the `elizabot.js` engine.

*   **Dual-Mode System:** The engine supports two modes, controlled by a `noRandom` flag.
    *   **Random Selection (Default):** The engine selects a reassembly template at random from the list of available options.
    *   **Cyclic Selection:** If the `noRandom` flag is set to `true`, the engine cycles through the responses in the order they are defined, using an internal counter to track the last-used response for each rule.

### 3. Memory System Rules

The rules for the memory queue in the `elizabot.js` implementation are clearly defined.

*   **Triggering:** A memory is saved when a decomposition rule prefixed with a `$` is matched.
*   **Storage:** The generated response is pushed into a FIFO (First-In, First-Out) queue with a default size of 20. If the queue is full, the oldest memory is discarded.
*   **Retrieval:** A memory is retrieved only when the engine cannot find any other matching rule for a new user input.
*   **Retrieval Policy:** Memory retrieval is **random** by default. If the `noRandom` flag is true, it retrieves the oldest memory from the queue sequentially.