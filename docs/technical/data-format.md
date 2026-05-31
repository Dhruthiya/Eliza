# ELIZA Script Data Format

The ELIZA engine is data-driven. The "personality" and behavior of the bot are defined in a set of JSON files. This document describes the structure and purpose of these data files, which are shared across the Elixir, Go, and Rust implementations.

## Overview

The script data is located in the `data/` directory. It is split into several files for modularity:

- `elizaInitials.json`: Initial greetings used by the bot.
- `elizaFinals.json`: Final messages sent when a session ends.
- `elizaQuits.json`: Keywords that trigger the end of a session.
- `elizaPres.json`: Pre-transformations (applied during normalization).
- `elizaPosts.json`: Post-transformations (applied during reassembly).
- `elizaSynons.json`: Synonym groups for pattern matching.
- `elizaKeywords.json`: The core logic—keywords, patterns, and reassemblies.

## JSON Structure

### Keywords (`elizaKeywords.json`)
This is the most complex file. It contains an array of keyword objects.

```json
{
  "keywords": [
    {
      "name": "computer",
      "rank": 50,
      "rules": [
        {
          "pattern": ["*", "computer", "*"],
          "reassembly": [
            "Do computers worry you?",
            "What do you think about machines?"
          ]
        }
      ]
    }
  ]
}
```

- **rank:** Higher rank keywords take precedence when multiple keywords are found in an input.
- **rules:** A list of decomposition patterns and their associated reassembly templates.

### Pre/Post Transformations
Stored as arrays of pairs.

```json
[
  ["don't", "do not"],
  ["i'm", "i am"]
]
```

## Pattern Syntax

- `*`: Greedy wildcard matching zero or more words.
- `literal`: Exact word match.
- `@synonym`: Matches any word in the specified synonym group (e.g., `@be` matches "am", "is", "are").

## Reassembly Syntax

- `(1)`, `(2)`, etc.: Substitutes the fragment captured by the corresponding wildcard in the pattern.
- `goto keyword`: Directs the engine to process rules for a different keyword.

## Engine Requirements

To support this data format, an engine must:
1. Load and parse all JSON files.
2. Sort keywords by rank descending.
3. Implement a recursive or backtracking matcher for the pattern syntax.
4. Handle the cyclic selection of reassembly rules to avoid repetitive responses.
