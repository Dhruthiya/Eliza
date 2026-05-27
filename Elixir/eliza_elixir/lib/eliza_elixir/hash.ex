defmodule Eliza.Hash do
  @moduledoc """
  Implements the deterministic mid-square hash function from the original ELIZA.
  This is used for selecting a MEMORY rule.
  """
  import Bitwise

  # From IBM 7094 BCD 6-bit character codes (in octal)
  @hollerith_map %{
    "A" => 0o21, "B" => 0o22, "C" => 0o23, "D" => 0o24, "E" => 0o25, "F" => 0o26,
    "G" => 0o27, "H" => 0o30, "I" => 0o31, "J" => 0o41, "K" => 0o42, "L" => 0o43,
    "M" => 0o44, "N" => 0o45, "O" => 0o46, "P" => 0o47, "Q" => 0o50, "R" => 0o51,
    "S" => 0o62, "T" => 0o63, "U" => 0o64, "V" => 0o65, "W" => 0o66, "X" => 0o67,
    "Y" => 0o70, "Z" => 0o71,
    "0" => 0o12, "1" => 0o01, "2" => 0o02, "3" => 0o03, "4" => 0o04, "5" => 0o05,
    "6" => 0o06, "7" => 0o07, "8" => 0o10, "9" => 0o11,
    "+" => 0o60, "-" => 0o40, "*" => 0o54, "/" => 0o55, "," => 0o33, "." => 0o73,
    "$" => 0o53, "=" => 0o34, "'" => 0o72, "(" => 0o75, ")" => 0o74,
    " " => 0o20
  }

  @doc """
  Converts a word into its 36-bit Hollerith integer representation.
  The original ELIZA used 6-character chunks (SLIP cells). This function
  simulates that by padding/truncating the word to 6 characters.
  """
  def to_hollerith(word) do
    word
    |> String.upcase()
    |> String.pad_trailing(6, " ")
    |> String.slice(0, 6)
    |> String.graphemes()
    |> Enum.reduce(0, fn char, acc ->
      char_val = Map.get(@hollerith_map, char, @hollerith_map[" "])
      (acc <<< 6) ||| char_val
    end)
  end

  @doc """
  The mid-square hash function HASH(D, N) from the discovered ELIZA source.
  """
  def hash(d, n) do
    d = d &&& 0x7FFFFFFFF # Use low 35 bits
    d = d * d
    d = d >>> (35 - div(n, 2))
    d &&& ((1 <<< n) - 1)
  end
end
