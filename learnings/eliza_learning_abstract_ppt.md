# ELIZA: My Learning Journey

## Slide 1 — From Curiosity to Reconstruction
**Title:** Rebuilding ELIZA, not just running it

- Started with the question: how did one of the first chatbots work?
- Studied Weizenbaum’s ELIZA and the DOCTOR script
- Realized the goal was not “modern AI”
- The goal was understanding how simple rules create believable conversation

**Speaker cue:**  
This project began as a reconstruction exercise. I was not trying to build a smarter chatbot first; I was trying to understand how a historically important chatbot created the illusion of intelligence.

---

## Slide 2 — Learning the Core Mechanism
**Title:** Intelligence from patterns

- ELIZA works through keyword ranking
- Inputs are normalized before matching
- Decomposition patterns capture parts of the user’s sentence
- Reassembly rules turn captures into responses
- Reflections like “your” → “my” make replies feel personal

**Speaker cue:**  
The biggest early learning was that ELIZA does not understand meaning. It uses a disciplined pipeline: clean the input, find keywords, match a pattern, transform captured words, and produce a response.

---

## Slide 3 — Turning Theory into Data
**Title:** The script became the system

- Separated the engine from the conversation script
- Converted ELIZA data into shared JSON files
- Organized initials, finals, quits, pres, posts, synonyms, and keywords
- Learned that good data structure makes multi-language implementation possible

**Speaker cue:**  
Once the rules were separated from the engine, the project became clearer. The same ELIZA personality could be reused across different implementations, which made the architecture more practical.

---

## Slide 4 — Implementing Across Languages
**Title:** Same idea, different tradeoffs

- Built implementations in Go, Rust, and Elixir-style architecture
- Go taught simple structure, web APIs, and concurrency safety
- Rust taught strict modeling, ownership, and testable components
- Elixir taught process state, functional flow, and runtime composition
- Each language exposed different assumptions in the same algorithm

**Speaker cue:**  
Rebuilding the same system in multiple languages forced me to separate the real algorithm from language-specific habits. If the design was unclear, every implementation exposed it differently.

---

## Slide 5 — Debugging the Hard Parts
**Title:** Small rules, subtle behavior

- Wildcards were harder than they looked
- Synonyms changed how patterns matched
- Memory rules required careful fallback behavior
- `goto` rules made the engine recursive
- Golden transcript tests helped verify behavior instead of guessing

**Speaker cue:**  
The difficult part was not writing a chatbot interface. The difficult part was matching ELIZA’s rule behavior accurately. Small choices in wildcard matching or response selection changed the whole conversation.

---

## Slide 6 — Final Learning
**Title:** What ELIZA taught me

- Simple systems can feel intelligent when interaction design is strong
- Architecture matters more when the same logic must run in many forms
- Tests are essential when behavior is historical and rule-based
- Modern AI is powerful, but ELIZA shows the foundation clearly
- I learned to move from research → model → implementation → verification

**Speaker cue:**  
The main takeaway is that ELIZA is small but deep. It taught me how to study an old system, extract its logic, rebuild it carefully, and compare behavior across implementations.

