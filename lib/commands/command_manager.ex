defmodule ElixirStuff.Commands do
  use Nostrum.Consumer
  require Logger
  alias Nostrum.Api

  def start_link do
    {:ok, _pid} = Agent.start_link(fn -> %{} end, name: __MODULE__)
    Nostrum.Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, {_map}, _ws_state}) do
    Enum.each(__MODULE__.__info__(:functions), fn {val, _arity} ->
      str_name = Atom.to_string(val)
      unless !String.starts_with?(str_name, "on_") do
        name = String.slice(str_name, 3..String.length(str_name))
        Logger.info "Adding #{name} command!"
        Agent.update(__MODULE__, fn state -> Map.put(state, "!#{name}", fn msg -> spawn fn -> Logger.info("Executing #{name}")apply(__MODULE__, val, [msg]) end end) end)
      end
    end)
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    unless !String.starts_with?(msg.content(), "!") do
      [head | _tail] = String.split(msg.content(), " ")
      got = Agent.get(__MODULE__, fn state -> Map.fetch(state, head) end)
      if got != :error, do: Kernel.elem(got, 1).(msg)
    end
  end

  def handle_event(_event), do: :noop
  def on_ping(msg), do: Api.create_message(msg.channel_id(), "Pong!")
end