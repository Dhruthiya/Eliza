 Slide 1: Title / Abstract
  Building ELIZA in Rust and Go: Learning Through Reimplementation

  - Objective: rebuild the ELIZA chatbot in multiple languages after first understanding its original logic and an initial
    Elixir version.
  - Focus of today’s presentation:
      - how we implemented ELIZA in Rust and Go
      - what challenges we faced
      - what mistakes we made
      - what we learned from each language
  - Main idea: the same chatbot logic can be expressed in very different programming styles depending on the language.

  Slide 2: From Understanding ELIZA to Rebuilding It

  - Yesterday’s work:
      - studied what ELIZA is
      - understood decomposition, keyword matching, reassembly, and memory
      - explored a basic Elixir implementation
  - Today’s work:
      - porting the same ELIZA behavior into Rust and Go
      - preserving the same core chatbot flow
      - comparing how different languages handle the same problem
  - Key takeaway:
      - the algorithm stayed mostly the same
      - the implementation style changed a lot

  Slide 3: Building ELIZA in Rust

  - Rust version focused on:
      - structured data models
      - parsing ELIZA script files
      - implementing decomposition and response generation
      - exposing the chatbot through a web/CLI interface
  - What we learned:
      - Rust is powerful for correctness and control
      - it forces careful thinking about ownership, mutable state, and structure
  - Initial difficulties:
      - handling shared state safely
      - understanding ownership/borrowing
      - writing code that compiles cleanly while preserving chatbot behavior

  Slide 4: Building ELIZA in Go

  - Go version focused on:
      - simple project structure
      - implementing the same ELIZA engine with less friction
      - adding a web interface using net/http
  - What we learned:
      - Go makes backend-style development very direct
      - concurrency and request handling feel simpler
      - the standard library is enough for many features
  - Initial difficulties:
      - managing shared conversation state correctly
      - making behavior consistent with earlier implementations

  Slide 5: Mistakes, Fixes, and Learning Process

  - Common mistakes we made:
      - misunderstanding how wildcard decomposition should capture components
      - inconsistent handling of memory/state across implementations
      - differences in matching/reassembly causing wrong replies
      - missing small historical behaviors like synonym handling or transform rules
  - How we fixed them:
      - compared outputs with expected ELIZA behavior
      - tested the same inputs across implementations
      - refined pattern matching and response selection logic
      - learned each language by debugging real implementation problems
  - Main lesson:
      - reimplementing the same system is one of the best ways to learn a language deeply

  Slide 6: Comparison and Conclusion

  - Rust taught us:
      - safety
      - explicit design
      - disciplined state handling
  - Go taught us:
      - simplicity
      - fast backend implementation
      - practical web service development
  - Elixir taught us earlier:
      - process-oriented thinking
      - state and concurrency through a different model
  - Final conclusion:
      - all three languages can build ELIZA
      - the biggest difference is not the chatbot logic, but how each language approaches structure, state, and concurrency
      - this project helped us learn both the ELIZA algorithm and the strengths of different programming languages
