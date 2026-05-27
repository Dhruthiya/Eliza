defmodule Eliza.DecomposerTest do
  use ExUnit.Case
  alias Eliza.Decomposer

  test "matches simple pattern without wildcards" do
    sentence = ["hello", "world"]
    pattern = ["hello", "world"]
    assert {:ok, ["hello", "world"]} = Decomposer.match(sentence, pattern)
  end

  test "matches pattern with single wildcard" do
    sentence = ["i", "am", "happy"]
    pattern = ["i", "am", :wildcard]
    assert {:ok, ["i", "am", "happy"]} = Decomposer.match(sentence, pattern)
  end

  test "matches pattern with wildcard in middle - greedy" do
    sentence = ["i", "think", "i", "love", "you"]
    pattern = [:wildcard, "i", :wildcard, "you", :wildcard]
    assert {:ok, ["", "i", "think i love", "you", ""]} = Decomposer.match(sentence, pattern)
  end

  test "fails when pattern doesn't match" do
    sentence = ["hello", "world"]
    pattern = ["goodbye", "world"]
    assert {:error, :no_match} = Decomposer.match(sentence, pattern)
  end
end
