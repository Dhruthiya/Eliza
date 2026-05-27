defmodule Eliza.GoldenTranscriptTest do
  use ExUnit.Case
  alias Eliza.{Engine, ScriptLoader, State}

  setup do
    case State.start_link([]) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
    end
    State.reset() # Reset state once before the entire conversation
    script = ScriptLoader.load_script()
    {:ok, script: script}
  end

  test "reproduces Weizenbaum's original conversation", %{script: script} do
    conversation = [
      {"Men are all alike.", "In what way"},
      {"They're always bugging us about something or other.", "Can you think of a specific example"},
      {"Well, my boyfriend made me come here.", "Your boyfriend made you come here ?"},
      {"He says I'm depressed much of the time.", "I am sorry to hear that you are depressed"},
      {"It's true. I am unhappy.", "Do you think coming here will help you not to be unhappy"},
      {"I need some help, that much seems certain.", "What would it mean to you if you got some help"},
      {"Perhaps I could learn to get along with my mother.", "Tell me more about your family"},
      {"My mother takes care of me.", "Who else in your family takes care of you ?"},
      {"My father.", "Your father"},
      {"You are like my father in some ways.", "What resemblance do you see"}
    ]

    Enum.each(conversation, fn {input, expected_start} ->
      {:ok, response} = Engine.transform(input, script)
      response_lower = String.downcase(response)
      expected_lower = String.downcase(expected_start)

      assert String.starts_with?(response_lower, expected_lower),
             "Input: '#{input}'\nExpected response to start with '#{expected_start}'\nBut got '#{response}'"
    end)
  end
end
