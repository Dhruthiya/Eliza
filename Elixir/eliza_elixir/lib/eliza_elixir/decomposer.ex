defmodule Eliza.Decomposer do
  @moduledoc """
  Implements the greedy wildcard matching algorithm for pattern decomposition.
  """

  @doc """
  Matches a sentence against a pattern and returns captured components.
  Returns {:ok, components} or {:error, :no_match}
  """
  def match(sentence, pattern) when is_list(sentence) and is_list(pattern) do
    case do_match(sentence, pattern) do
      {:ok, components} -> {:ok, components}
      error -> error
    end
  end

  defp do_match(sentence, pattern) do
    do_match_helper(sentence, pattern, [])
  end

  # Both empty - success
  defp do_match_helper([], [], acc), do: {:ok, Enum.reverse(acc)}

  # Pattern done, sentence remains - fail
  defp do_match_helper(_sent, [], _acc), do: {:error, :no_match}

  # Sentence done, pattern has wildcard - capture empty
  defp do_match_helper([], [:wildcard | rest], acc) do
    do_match_helper([], rest, ["" | acc])
  end

  # Sentence done, pattern has non-wildcard - fail
  defp do_match_helper([], _pattern, _acc), do: {:error, :no_match}

  # Wildcard - greedy matching
  defp do_match_helper(sentence, [:wildcard | pattern_rest], acc) do
    greedy_wildcard(sentence, pattern_rest, acc)
  end

  # Exact match (don't capture keywords)
  defp do_match_helper([word | sent_rest], [word | pattern_rest], acc) do
    do_match_helper(sent_rest, pattern_rest, acc)
  end

  # Mismatch
  defp do_match_helper(_sentence, _pattern, _acc), do: {:error, :no_match}

  # Greedy wildcard: capture as much as possible
  defp greedy_wildcard(sentence, [], acc) do
    # No more pattern - wildcard takes everything
    {:ok, Enum.reverse([Enum.join(sentence, " ") | acc])}
  end

  defp greedy_wildcard(sentence, [:wildcard | _] = pattern_rest, acc) do
    # Next is wildcard - current wildcard captures nothing
    do_match_helper(sentence, pattern_rest, ["" | acc])
  end

  defp greedy_wildcard(sentence, [next_word | _] = pattern_rest, acc) do
    # For greedy matching: try first occurrence first
    # This allows later wildcards to be greedy
    all_positions = find_all_positions(sentence, next_word)
    
    case all_positions do
      [] -> {:error, :no_match}
      positions ->
        # Try positions from first to last (allows later wildcards to be greedy)
        try_positions(sentence, positions, pattern_rest, acc)
    end
  end

  defp find_all_positions(words, target) do
    words
    |> Enum.with_index()
    |> Enum.filter(fn {word, _idx} -> word == target end)
    |> Enum.map(fn {_word, idx} -> idx end)
  end

  defp try_positions(_sentence, [], _pattern_rest, _acc), do: {:error, :no_match}

  defp try_positions(sentence, [pos | rest_positions], pattern_rest, acc) do
    {before, remaining} = Enum.split(sentence, pos)
    captured = Enum.join(before, " ")
    
    case do_match_helper(remaining, pattern_rest, [captured | acc]) do
      {:ok, _} = success -> success
      {:error, :no_match} -> try_positions(sentence, rest_positions, pattern_rest, acc)
    end
  end
end
