defmodule Eliza.Engine do
  @moduledoc """
  Main ELIZA engine that orchestrates the transformation process.
  """

  alias Eliza.{Decomposer, Transformer, State, Script}

  @doc """
  Transforms user input into ELIZA response.
  """
  def transform(input, %Script{} = script) do
    normalized = normalize_input(input, script.pres)
    words = String.split(normalized) |> Enum.map(&String.downcase/1)

    # Check for quit
    if Enum.any?(script.quits, &(&1 in words)) do
      {:quit, Enum.random(script.finals)}
    else
      response = find_response(words, script)
      {:ok, response}
    end
  end

  defp normalize_input(input, pres) do
    input
    |> String.downcase()
    |> String.replace(~r/[^\w\s]/, " ")
    |> apply_transformations(pres)
  end

  defp apply_transformations(text, transformations) do
    Enum.reduce(transformations, text, fn {pattern, replacement}, acc ->
      String.replace(acc, pattern, replacement)
    end)
  end

  defp find_response(words, script) do
    # Try to match keywords in rank order
    Enum.find_value(script.keywords, fn keyword ->
      if keyword.name in words or keyword.name == "xnone" do
        try_keyword_rules(words, keyword, script)
      end
    end) || get_fallback(script)
  end

  defp try_keyword_rules(words, keyword, script) do
    Enum.with_index(keyword.rules)
    |> Enum.find_value(fn {rule, rule_index} ->
      case Decomposer.match(words, rule.pattern) do
        {:ok, components} ->
          process_match(components, rule, keyword, rule_index, script, words)

        {:error, :no_match} ->
          nil
      end
    end)
  end

  defp process_match(components, rule, keyword, rule_index, script, words) do
    # Transform components
    transformed = Transformer.transform_components(components, script.posts)

    # Get response using cyclic selection
    reassembly_list = rule.reassembly
    response_idx = State.get_next_response_index(keyword.name, rule_index, length(reassembly_list))
    template = Enum.at(reassembly_list, response_idx)

    # Handle goto
    response = 
      if String.starts_with?(template, "goto ") do
        goto_keyword = String.trim_leading(template, "goto ")
        handle_goto(words, goto_keyword, script)
      else
        Transformer.reassemble(template, transformed)
      end

    # Handle memory
    if rule.is_memory_rule do
      State.save_memory(response)
      nil
    else
      response
    end
  end

  defp handle_goto(words, keyword_name, script) do
    keyword = Enum.find(script.keywords, &(&1.name == keyword_name))
    if keyword do
      try_keyword_rules(words, keyword, script) || get_fallback(script)
    else
      get_fallback(script)
    end
  end

  defp get_fallback(script) do
    # Try memory first
    case State.get_memory() do
      nil ->
        # Use xnone keyword
        xnone = Enum.find(script.keywords, &(&1.name == "xnone"))
        if xnone do
          rule = hd(xnone.rules)
          Enum.random(rule.reassembly)
        else
          "I'm not sure I understand."
        end

      memory_response ->
        memory_response
    end
  end
end
