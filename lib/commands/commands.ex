defmodule ElixirStuff.Commands.List do
  alias Nostrum.Api
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