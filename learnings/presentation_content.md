We start by talking about ELIZA.

Claude, ChatGPT, Gemini, and all of these LLMs have emerged in the new age, but when did it all start? Did it start in the 2010s? Did it start in 2012 or in 2005? No, it goes way back than this. It all started in the 1960s. Or when was it, the 1970s? Yeah, it all started in the 1960s. Alan Turing wrote the first papers in AI. Now, we wanted to see which was one of the first few chatbots that humans tried to make so that they could talk to a bot, to the computer. And that’s when Asokan told about ELIZA. 

Something that is very interesting about ELIZA is that it uses pattern matching and simple string hashing to generate such kind of responses. But whereas Claude and ChatGPT depend heavily on neural networks, what is fascinating is that with such a simple natural language processing algorithm, it is able to generate such an application that humans get connected to emotionally. So the initial response when ELIZA was actually released was that people started getting connected emotionally to it because of the way ELIZA was. Yeah, obviously. So ELIZA predominantly mimicked a Rogerian therapist, so it played around safe. Safe in the sense that it was non-directional. It was not directing anything to the users. It responds in such a way that it is natural, but at the same time it is safe. It does not cross that directive boundary.

Like so thrilled, we even wondered if it could actually work. Because patterns such good results and somehow convince people right? And somehow convince people that it can do wonders, and it can get them hooked to it is something interesting.

Another interesting point about implementation is that, for starting the implementation, we went through other documents, which is the doctor script, which is written by Joseph Eisenburg, and then we went through all of that and understood the implementation and internal working of ELIZA.

But I think it’s an idea, and then we implemented it. The most interesting part is that we implemented this in 3 languages: Elixir, Go, and Rust.

We’ve never worked on Go and Rust before. For Elixir, we built our previous project with Elixir, but Go and Rust were completely out of our territory. We learned them, and we built them parallelly. We initially did the project in Elixir that we knew, so from that project, since we knew the language, we could easily build it, but we did not know Go and Rust.

So we slowly built Elixir and then translated the script to that. In order to translate, we had to learn both the languages and go through all the syntax and documentation and all to understand it. The working in order to translate from one language to another.

And then the key discovery that we made was that we actually made this project in iterations, like it is done in software companies where basic output is first given in order to, you know, be safe. Don’t say this, okay, this is bad, we’ll get into trouble. Okay, we just say that this project was built in iterations, so first we delivered different phases, iterations, we first delivered version 1 and then we delivered version 2.

The project to be always running, a running model should always be there. Yes, a running model should always be there, like every time we delivered. We wanted to ensure that ELIZA was working, so we delivered it in iterations. Version 1 was the completely working version, but this version 1 was built with us knowing ELIZA only for about 60%.

So 40% of the logic was missing. What we tried to do was we could somehow read Weizenbaum’s papers and get some 10% of the logic. But 30% of the logic remained clueless. So for that, what we did was we went around exploring stuff.

Then we came across Anthony Haste’s recreation of ELIZA. What he did was he went through MIT’s archives, and he found some of ELIZA’s scripts written in mad slips. He transcribed them and then recreated and understood the logic, and he recovered the remaining 30% of the missing data, sorry, missing logic, and then he recreated that in C++ and went on to writing a book about it.

So then you can show the article, his article from part one, yeah, and then we implemented our version 2 after recovering the remaining 30%. And that’s how we built the, we recreated ELIZA.

This helped us in understanding how 3 languages worked in a different way while handling the same problem, so we have to mention how Go, well, let’s say Rust, work differently. But it gave the same output at the same time.

Yeah, we haven’t changed the core logic, but we made sure that in each implementation, we were leveraging the language ability to make the code efficient in the ways it could possibly do. So that’s something we ensured, and that was one of the main agendas while implementing in the different languages, but ensuring that the core logic remained the same.
