defmodule Eliza.Transformer do
  @moduledoc """
  Handles component transformation (pronoun reflection) and reassembly.
  """

  @doc """
  Transforms captured components using post-transformation rules.
  """
  def transform_components(components, posts) do
    Enum.map(components, fn component ->
      component
      |> String.split()
      |> Enum.map(&(Map.get(posts, &1, &1)))
      |> Enum.join(" ")
    end)
  end

  @doc """
  Reassembles response by substituting components into template.
  """
  def reassemble(template, components) do
    Regex.replace(~r/\((\d+)\)/, template, fn _, num ->
      idx = String.to_integer(num) - 1
      Enum.at(components, idx, "")
    end)
  end
end
