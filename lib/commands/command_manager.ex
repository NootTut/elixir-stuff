defmodule ElixirStuff.Commands do
  use Nostrum.Consumer
  require Logger
  alias Nostrum.Api

  def start_link do
    {:ok, _pid} = Agent.start_link(fn -> %{} end, name: __MODULE__)
    Nostrum.Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, {_map}, _ws_state}) do
    for {val, _arity} <- __MODULE__.__info__(:functions) do
      str_name = Atom.to_string(val)
      unless !String.starts_with?(str_name, "on_") do
        name = String.slice(str_name, 3..String.length(str_name))
        Logger.info "Adding #{name} command!"
        Agent.update(__MODULE__, fn state -> Map.put(state, "!#{name}", fn msg -> spawn fn -> apply(__MODULE__, val, [msg]) end end) end)
      end
    end
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    unless !String.starts_with?(msg.content(), "!") do
      [head | _tail] = String.split(msg.content(), " ")
      got = Agent.get(__MODULE__, fn state -> Map.fetch(state, head) end)
      if got != :error, do: elem(got, 1).(msg)
    end
  end

  def handle_event(_event), do: :noop
  def on_ping(msg), do: Api.create_message(msg.channel_id(), "Pong!")

  def on_eval(msg) do
    if msg.author().id() != 199217346911404032 do
      Api.create_message(msg.channel_id(), "You cannot evaluate code!")
    else
      [head | _tail] = String.split(msg.content(), " ")
      try do
        {result, _bindings} = msg.content()
        |> String.slice(String.length(head)..String.length(msg.content()))
        |> Code.eval_string([msg: msg], __ENV__)
        Api.create_message(msg.channel_id(), "```#{inspect result}```")
      rescue
        e -> Api.create_message(msg.channel_id(), "An error occurred: #{inspect e}")
      catch
        e -> Api.create_message(msg.channel_id(), "An error occurred: #{inspect e}")
      end
    end
  end


end