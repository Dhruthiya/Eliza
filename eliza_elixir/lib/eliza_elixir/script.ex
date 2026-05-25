defmodule Eliza.Script.Rule do
  @moduledoc """
  Represents a decomposition/reassembly rule.
  """
  defstruct pattern: [],
            reassembly: [],
            is_memory_rule: false
end

defmodule Eliza.Script.Keyword do
  @moduledoc """
  Represents a keyword with its rank and associated rules.
  """
  defstruct name: "",
            rank: 0,
            rules: []
end

defmodule Eliza.Script do
  @moduledoc """
  Represents the complete ELIZA script data.
  """
  defstruct initials: [],
            finals: [],
            quits: [],
            pres: %{},
            posts: %{},
            synons: %{},
            keywords: [],
            post_transforms: []
end
