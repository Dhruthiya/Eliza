#!/usr/bin/env elixir

Mix.install([
  {:jason, "~> 1.4"},
  {:plug, "~> 1.14"},
  {:bandit, "~> 1.0"}
])

Code.require_file("../lib/eliza_elixir/script.ex", __DIR__)
Code.require_file("../lib/eliza_elixir/script_loader.ex", __DIR__)
Code.require_file("../lib/eliza_elixir/decomposer.ex", __DIR__)
Code.require_file("../lib/eliza_elixir/transformer.ex", __DIR__)
Code.require_file("../lib/eliza_elixir/state.ex", __DIR__)
Code.require_file("../lib/eliza_elixir/engine.ex", __DIR__)

{:ok, _pid} = Eliza.State.start_link([])
script = Eliza.ScriptLoader.load_script("/home/cse/eliza/data")

defmodule ElizaWeb do
  import Plug.Conn

  def init(script), do: script

  def call(conn, script) do
    conn = fetch_query_params(conn)
    route(conn, conn.method, conn.path_info, script)
  end

  defp route(conn, "GET", [], _script) do
    html = File.read!("index.html")
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  defp route(conn, "POST", ["chat"], script) do
    {:ok, body, conn} = read_body(conn)
    %{"message" => message} = Jason.decode!(body)
    
    {:ok, response} = Eliza.Engine.transform(message, script)
    
    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("access-control-allow-origin", "*")
    |> send_resp(200, Jason.encode!(%{response: response}))
  end

  defp route(conn, _, _, _) do
    send_resp(conn, 404, "Not found")
  end
end

IO.puts("\n╔════════════════════════════════════════╗")
IO.puts("║     ELIZA Web Server Started!         ║")
IO.puts("╚════════════════════════════════════════╝")
IO.puts("\n➜ Open: http://localhost:4000")
IO.puts("➜ Press Ctrl+C to stop\n")

{:ok, _} = Bandit.start_link(plug: {ElizaWeb, script}, port: 4000)
Process.sleep(:infinity)
