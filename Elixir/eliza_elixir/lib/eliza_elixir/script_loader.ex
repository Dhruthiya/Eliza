defmodule Eliza.ScriptLoader do
  @moduledoc """
  Loads ELIZA script data from JSON files.
  """

  alias Eliza.Script
  alias Eliza.Script.Keyword
  alias Eliza.Script.Rule

  def load_script(base_path \\ nil) do
    data_path = base_path || Path.join([__DIR__, "../../data"])
    
    %Script{
      initials: load_json(data_path, "elizaInitials.json"),
      finals: load_json(data_path, "elizaFinals.json"),
      quits: load_json(data_path, "elizaQuits.json"),
      pres: load_pairs_map(data_path, "elizaPres.json"),
      posts: load_pairs_map(data_path, "elizaPosts.json"),
      synons: load_json_map(data_path, "elizaSynons.json"),
      keywords: load_keywords(data_path, "elizaKeywords.json"),
      post_transforms: load_json(data_path, "elizaPostTransforms.json")
    }
  end

  defp load_json(base_path, filename) do
    path = Path.join(base_path, filename)
    path |> File.read!() |> Jason.decode!()
  end

  defp load_pairs_map(base_path, filename) do
    data = load_json(base_path, filename)
    Enum.map(data, fn [k, v] -> {k, v} end) |> Map.new()
  end

  defp load_json_map(base_path, filename) do
    load_json(base_path, filename)
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
      "*" -> :wildcard
      word -> String.downcase(word)
    end)
  end
end
