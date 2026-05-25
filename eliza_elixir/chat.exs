#!/usr/bin/env elixir

Mix.install([{:jason, "~> 1.4"}])

Code.require_file("lib/eliza_elixir/script.ex", __DIR__)
Code.require_file("lib/eliza_elixir/script_loader.ex", __DIR__)
Code.require_file("lib/eliza_elixir/decomposer.ex", __DIR__)
Code.require_file("lib/eliza_elixir/transformer.ex", __DIR__)
Code.require_file("lib/eliza_elixir/state.ex", __DIR__)
Code.require_file("lib/eliza_elixir/engine.ex", __DIR__)

{:ok, _pid} = Eliza.State.start_link([])
script = Eliza.ScriptLoader.load_script("/home/cse/eliza/data")

IO.puts("\n╔════════════════════════════════════════╗")
IO.puts("║   ELIZA - Interactive Test Session    ║")
IO.puts("╚════════════════════════════════════════╝\n")
IO.puts(Enum.random(script.initials) <> "\n")
IO.puts("Type your message (or 'quit' to exit)\n")

defmodule Chat do
  def loop(script) do
    input = IO.gets("YOU: ") |> String.trim()
    
    case Eliza.Engine.transform(input, script) do
      {:quit, final} ->
        IO.puts("ELIZA: #{final}\n")
        
      {:ok, response} ->
        IO.puts("ELIZA: #{response}\n")
        loop(script)
    end
  end
end

Chat.loop(script)
