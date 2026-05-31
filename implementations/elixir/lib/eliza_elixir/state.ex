defmodule Eliza.State do
  @moduledoc """
  Manages conversation state including response cycling and memory.
  """
  use Agent

  defstruct response_index: %{},
            memory: [],
            limit: 0

  def start_link(_opts) do
    Agent.start_link(fn -> %__MODULE__{} end, name: __MODULE__)
  end

  # --- Limit Counter ---

  @doc """
  Increments the limit counter, cycling 1 -> 2 -> 3 -> 4 -> 1, and returns the new value.
  """
  def increment_and_get_limit do
    Agent.get_and_update(__MODULE__, fn state ->
      new_limit = rem(state.limit, 4) + 1
      {new_limit, %{state | limit: new_limit}}
    end)
  end

  # --- Response Cycling ---

  @doc """
  Gets next response index for a given keyword and rule.
  Cycles through reassembly options.
  """
  def get_next_response_index(keyword_name, rule_index, max_index) do
    Agent.get_and_update(__MODULE__, fn state ->
      key = {keyword_name, rule_index}
      current = Map.get(state.response_index, key, 0)
      # rem/2 ensures we don't go out of bounds if rules change during dev
      current_safe = rem(current, max_index)
      next = rem(current + 1, max_index)
      new_state = %{state | response_index: Map.put(state.response_index, key, next)}
      {current_safe, new_state}
    end)
  end

  # --- Memory ---

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

  # --- General ---

  @doc """
  Resets conversation state.
  """
  def reset do
    Agent.update(__MODULE__, fn _state ->
      %__MODULE__{}
    end)
  end
end
