defmodule ElixirStuff do
  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    if msg.author().bot() do
      :ignored
    else
      [head | tail] = msg.content() |> String.split()
      case head |> String.downcase() do
       "echo" -> msg.channel_id() |> Api.create_message(tail |> Enum.join(" "))
        _ -> :ignored
      end
    end
  end

  def handle_event(_event) do
    :noop
  end
end
