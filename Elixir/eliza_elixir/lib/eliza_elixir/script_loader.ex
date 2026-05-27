defmodule Eliza.ScriptLoader do
  @moduledoc """
  Loads ELIZA script data from JSON files.
  """

  alias Eliza.Script
  alias Eliza.Script.Keyword
  alias Eliza.Script.Rule

  def load_script(base_path \\ nil) do
    data_path = base_path || default_data_path()

    all_keywords = load_keywords(data_path, "elizaKeywords.json")

    {memory_pattern, memory_templates, final_keywords} = extract_memory_rule(all_keywords)

    %Script{
      initials: load_json(data_path, "elizaInitials.json"),
      finals: load_json(data_path, "elizaFinals.json"),
      quits: load_json(data_path, "elizaQuits.json"),
      pres: load_pairs_map(data_path, "elizaPres.json"),
      posts: load_pairs_map(data_path, "elizaPosts.json"),
      synons: load_synons(data_path, "elizaSynons.json"),
      keywords: final_keywords,
      memory_pattern: memory_pattern,
      memory_templates: memory_templates,
      post_transforms: load_post_transforms(data_path, "elizaPostTransforms.json")
    }
  end

  defp extract_memory_rule(keywords) do
    memory_keyword_name = "my"
    {memory_pattern, memory_templates} =
      if my_kw = Enum.find(keywords, &(&1.name == memory_keyword_name)) do
        if mem_rule = Enum.find(my_kw.rules, &(&1.is_memory_rule)) do
          if length(mem_rule.reassembly) != 4 do
            raise "MEMORY rule for '#{memory_keyword_name}' must have exactly 4 reassembly templates."
          end
          {mem_rule.pattern, mem_rule.reassembly}
        else
          {[], []} # No memory rule found inside "my" keyword
        end
      else
        {[], []} # "my" keyword not found
      end

    # Remove the memory rule from the keyword list to avoid double processing
    final_keywords =
      Enum.map(keywords, fn kw ->
        if kw.name == memory_keyword_name do
          %{kw | rules: Enum.reject(kw.rules, &(&1.is_memory_rule))}
        else
          kw
        end
      end)

    {memory_pattern, memory_templates, final_keywords}
  end

  defp default_data_path do
    Path.expand(Path.join([__DIR__, "../../../../data"]))
  end

  defp load_json(base_path, filename) do
    path = Path.join(base_path, filename)
    path |> File.read!() |> Jason.decode!()
  end

  defp load_pairs_map(base_path, filename) do
    data = load_json(base_path, filename)
    Enum.map(data, fn [k, v] -> {k, v} end) |> Map.new()
  end

  defp load_synons(base_path, file) do
    load_json(base_path, file)
    |> Enum.reduce(%{}, fn {key, values}, acc ->
      Enum.reduce(values, acc, fn value, inner_acc ->
        Map.put(inner_acc, value, key)
      end)
    end)
  end

  defp load_keywords(base_path, filename) do
    data = load_json(base_path, filename)

    Enum.map(data, fn [name, rank, rules] ->
      %Keyword{
        name: name,
        rank: rank,
        rules: parse_rules(rules)
      }
    end)
    |> Enum.sort_by(& &1.rank, :desc)
  end

  defp parse_rules(rules) do
    Enum.map(rules, fn [pattern, reassembly] ->
      {is_memory, clean_pattern} =
        if is_binary(pattern) and String.starts_with?(pattern, "$") do
          {true, String.trim_leading(pattern, "$ ")}
        else
          {false, pattern}
        end

      %Rule{
        pattern: parse_pattern(clean_pattern),
        reassembly: reassembly,
        is_memory_rule: is_memory
      }
    end)
  end

  defp parse_pattern(pattern) when is_binary(pattern) do
    pattern
    |> String.split()
    |> Enum.map(fn
      "*" ->
        :wildcard

      "@" <> rest ->
        {:synonym_group, String.downcase(rest)}

      word ->
        String.downcase(word)
    end)
  end

  defp load_post_transforms(base, file) do
    load_json(base, file)
    |> Enum.map(fn [find, replace] ->
      {Regex.compile!("\\b#{find}\\b", "i"), replace}
    end)
  end
end
