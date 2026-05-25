defmodule Eliza.State do
  @moduledoc """
  Manages conversation state including response cycling and memory.
  """
  use Agent

  defstruct response_index: %{},
            memory: []

  def start_link(_opts) do
    Agent.start_link(fn -> %__MODULE__{} end, name: __MODULE__)
  end

  @doc """
  Gets next response index for a given keyword and rule.
  Cycles through reassembly options.
  """
  def get_next_response_index(keyword_name, rule_index, max_index) do
    Agent.get_and_update(__MODULE__, fn state ->
      key = {keyword_name, rule_index}
      current = Map.get(state.response_index, key, 0)
      next = rem(current + 1, max_index)
      new_state = %{state | response_index: Map.put(state.response_index, key, next)}
      {current, new_state}
    end)
  end

  @doc """
  Saves a response to memory.
  """
  def save_memory(response) do
    Agent.update(__MODULE__, fn state ->
      %{state | memory: [response | state.memory]}
    end)
  end

  @doc """
  Retrieves and removes oldest memory.
  """
  def get_memory do
    Agent.get_and_update(__MODULE__, fn state ->
      case Enum.reverse(state.memory) do
        [] -> {nil, state}
        [oldest | rest] -> {oldest, %{state | memory: Enum.reverse(rest)}}
      end
    end)
  end

  @doc """
  Resets conversation state.
  """
  def reset do
    Agent.update(__MODULE__, fn _state ->
      %__MODULE__{}
    end)
  end
end
