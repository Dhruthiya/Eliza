defmodule ElizaElixirTest do
  use ExUnit.Case
  doctest ElizaElixir

  test "greets the world" do
    assert ElizaElixir.hello() == :world
  end
end
