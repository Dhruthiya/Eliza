#!/usr/bin/env elixir

# Start ELIZA CLI
Mix.install([{:jason, "~> 1.4"}])

Code.require_file("lib/eliza_elixir/script.ex", __DIR__)
Code.require_file("lib/eliza_elixir/script_loader.ex", __DIR__)
Code.require_file("lib/eliza_elixir/decomposer.ex", __DIR__)
Code.require_file("lib/eliza_elixir/transformer.ex", __DIR__)
Code.require_file("lib/eliza_elixir/state.ex", __DIR__)
Code.require_file("lib/eliza_elixir/engine.ex", __DIR__)
Code.require_file("lib/eliza_elixir/cli.ex", __DIR__)

{:ok, _pid} = Eliza.State.start_link([])
Eliza.CLI.start()
