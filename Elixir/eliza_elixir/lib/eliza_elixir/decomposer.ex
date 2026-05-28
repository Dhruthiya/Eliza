defmodule Eliza.Decomposer do
  @moduledoc """
  Implements the greedy wildcard matching algorithm for pattern decomposition.
  """

  @doc """
  Matches a sentence against a pattern and returns captured components.
  Optionally takes a synons map for synonym group matching.
  Returns {:ok, components} or {:error, :no_match}
  """
  def match(sentence, pattern, synons \\ %{}) when is_list(sentence) and is_list(pattern) do
    case do_match(sentence, pattern, synons) do
      {:ok, components} -> {:ok, components}
      error -> error
    end
  end

  defp do_match(sentence, pattern, synons) do
    do_match_helper(sentence, pattern, synons, [])
  end

  # Both empty - success
  defp do_match_helper([], [], _synons, acc), do: {:ok, Enum.reverse(acc)}

  # Pattern done, sentence remains - fail
  defp do_match_helper(_sent, [], _synons, _acc), do: {:error, :no_match}

  # Sentence done, pattern has wildcard - capture empty
  defp do_match_helper([], [:wildcard | rest], synons, acc) do
    do_match_helper([], rest, synons, ["" | acc])
  end

  # Sentence done, pattern has non-wildcard - fail
  defp do_match_helper([], _pattern, _synons, _acc), do: {:error, :no_match}

  # Wildcard - greedy matching
  defp do_match_helper(sentence, [:wildcard | pattern_rest], synons, acc) do
    greedy_wildcard(sentence, pattern_rest, synons, acc)
  end

  # Exact match - literals are not captured.
  defp do_match_helper([word | sent_rest], [word | pattern_rest], synons, acc) do
    do_match_helper(sent_rest, pattern_rest, synons, acc)
  end

  # Synonym group match - capture the matched word
  defp do_match_helper([word | sent_rest], [{:synonym_group, group} | pattern_rest], synons, acc) do
    if is_synonym?(word, group, synons) do
      do_match_helper(sent_rest, pattern_rest, synons, [word | acc])
    else
      {:error, :no_match}
    end
  end

  # Mismatch
  defp do_match_helper(_sentence, _pattern, _synons, _acc), do: {:error, :no_match}

  # Greedy wildcard: capture as much as possible
  defp greedy_wildcard(sentence, [], _synons, acc) do
    # No more pattern - wildcard takes everything
    {:ok, Enum.reverse([Enum.join(sentence, " ") | acc])}
  end

  defp greedy_wildcard(sentence, [:wildcard | _] = pattern_rest, synons, acc) do
    # Next is wildcard - current wildcard captures nothing
    do_match_helper(sentence, pattern_rest, synons, ["" | acc])
  end

  defp greedy_wildcard(sentence, [next_token | _] = pattern_rest, synons, acc) do
    # For greedy matching: try first matching occurrence first.
    all_positions = find_all_positions(sentence, next_token, synons)
    
    case all_positions do
      [] -> {:error, :no_match}
      positions ->
        # Try positions from first to last (allows later wildcards to be greedy)
        try_positions(sentence, positions, pattern_rest, synons, acc)
    end
  end

  defp find_all_positions(words, {:synonym_group, group}, synons) do
    words
    |> Enum.with_index()
    |> Enum.filter(fn {word, _idx} -> is_synonym?(word, group, synons) end)
    |> Enum.map(fn {_word, idx} -> idx end)
  end

  defp find_all_positions(words, target, _synons) do
    words
    |> Enum.with_index()
    |> Enum.filter(fn {word, _idx} -> word == target end)
    |> Enum.map(fn {_word, idx} -> idx end)
  end

  defp try_positions(_sentence, [], _pattern_rest, _synons, _acc), do: {:error, :no_match}

  defp try_positions(sentence, [pos | rest_positions], pattern_rest, synons, acc) do
    {before, remaining} = Enum.split(sentence, pos)
    captured = Enum.join(before, " ")
    
    case do_match_helper(remaining, pattern_rest, synons, [captured | acc]) do
      {:ok, _} = success -> success
      {:error, :no_match} -> try_positions(sentence, rest_positions, pattern_rest, synons, acc)
    end
  end

  # Check if word is in synonym group
  defp is_synonym?(word, group, synons) do
    Map.get(synons, word) == group or word == group
  end
end
