defmodule ElixirStuff.Commands.Manager do
  use Nostrum.Consumer
  require Logger

  @prefix ">>"

  def start_link do
    {:ok, _pid} = Agent.start_link(fn -> %{} end, name: __MODULE__)
    Nostrum.Consumer.start_link(__MODULE__)

  end

  def handle_event({:READY, {_map}, _ws_state}) do
    for {val, _arity} <- ElixirStuff.Commands.List.__info__(:functions) do
      str_name = Atom.to_string(val)
      unless !String.starts_with?(str_name, "on_") do
        name = String.slice(str_name, 3..String.length(str_name))
        Logger.info "Adding #{name} command!"
        Agent.update(__MODULE__, fn state -> Map.put(state, "#{@prefix}#{name}", fn msg -> spawn fn -> apply(ElixirStuff.Commands.List, val, [msg]) end end) end)
      end
    end
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    unless !String.starts_with?(msg.content(), @prefix) do
      [head | _tail] = String.split(msg.content(), " ")
      got = Agent.get(__MODULE__, fn state -> Map.fetch(state, head) end)
      if got != :error, do: elem(got, 1).(msg)
    end
  end

  def handle_event(_event), do: :noop
end