defmodule Eliza.CLI do
  @moduledoc """
  Command-line interface for ELIZA.
  """

  alias Eliza.{Engine, ScriptLoader, State}

  def start do
    IO.puts("\n=== ELIZA - The Original Chatbot ===\n")
    
    script = ScriptLoader.load_script("/home/cse/eliza/data")
    State.reset()
    
    initial = Enum.random(script.initials)
    IO.puts("ELIZA: #{initial}\n")
    
    loop(script)
  end

  defp loop(script) do
    input = IO.gets("YOU: ") |> String.trim()
    
    case Engine.transform(input, script) do
      {:quit, final} ->
        IO.puts("ELIZA: #{final}")
        IO.puts("\nGoodbye!\n")
        
      {:ok, response} ->
        IO.puts("ELIZA: #{response}\n")
        loop(script)
    end
  end
end
