defmodule ElixirStuff.Supervisor do
  use Supervisor

  def start_link(opts) do
    __MODULE__ |> Supervisor.start_link(:ok, opts)
  end

  def init(:ok) do
    [ElixirStuff] |> Supervisor.init(strategy: :one_for_one)
  end
end