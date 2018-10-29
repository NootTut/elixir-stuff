defmodule ElixirStuff.Application do
  use Application
  def start(_type, _args), do: ElixirStuff.Commands.Supervisor.start_link([])
end