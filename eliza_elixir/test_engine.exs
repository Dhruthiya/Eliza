#!/usr/bin/env elixir

# Simple test of ELIZA engine
Mix.install([{:jason, "~> 1.4"}])

Code.require_file("lib/eliza_elixir/script.ex", __DIR__)
Code.require_file("lib/eliza_elixir/script_loader.ex", __DIR__)
Code.require_file("lib/eliza_elixir/decomposer.ex", __DIR__)
Code.require_file("lib/eliza_elixir/transformer.ex", __DIR__)
Code.require_file("lib/eliza_elixir/state.ex", __DIR__)
Code.require_file("lib/eliza_elixir/engine.ex", __DIR__)

# Start state agent
{:ok, _pid} = Eliza.State.start_link([])

# Load script
IO.puts("Loading ELIZA script...")
script = Eliza.ScriptLoader.load_script("/home/cse/eliza/data")

IO.puts("Script loaded successfully!")
IO.puts("Keywords: #{length(script.keywords)}")
IO.puts("Initials: #{length(script.initials)}")
IO.puts("\nTesting engine...\n")

# Test some inputs
test_inputs = [
  "Hello",
  "I am feeling sad",
  "I remember my mother",
  "My father was strict"
]

Enum.each(test_inputs, fn input ->
  {:ok, response} = Eliza.Engine.transform(input, script)
  IO.puts("YOU: #{input}")
  IO.puts("ELIZA: #{response}\n")
end)

IO.puts("✓ Basic engine test complete!")
