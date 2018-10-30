defmodule ElixirStuff.Commands.List do
  alias Nostrum.Api

  @owner_id 199_217_346_911_404_032
  @bot_color 4_224_767
  @error_color 16_725_555
  @warning_color 16_736_000

  @random 0..10

  def on_ping(msg), do: Api.create_message(msg.channel_id(), embed: embed(msg, description: "Pong!"))

  def echo(msg) do
    [head | _tail] = String.split(msg.content(), " ")
    Api.create_message(msg.channel_id(),
      embed: embed(msg, description: String.slice(msg.content(), String.length(head), String.length(msg.content()))))
  end

  def dice(msg) do
    [_head | tail] = String.split(msg.content(), " ")
    if length(tail) == 0 do
      Api.create_message(msg.channel_id(), embed: embed(msg, description: "you have to specify a number smh", color: @warning_color))
    else
      num = tail
      |> Enum.at(0)
      |> Integer.parse()
      Api.create_message(msg.channel_id(), embed: embed(msg, description: "#{Enum.random(1..num)}"))
    end
  end
  
  def gay(msg), do: Api.create_message(msg.channel_id(), embed: embed(msg, description: "tut is gay but also awesome <3"))

  def rate(msg) do
    [head | _tail] = String.split(msg.content(), " ")
    rated = String.slice(msg.content(), String.length(head), String.length(msg.content()))
    Api.create_message(msg.channel_id(),
      embed: embed(msg, description: "I rate #{rated} a #{Enum.random(@random)}/10!"))
  end

  def on_eval(msg) do
    if msg.author().id() != @owner_id do
      Api.create_message(msg.channel_id(), embed: embed(msg, description: "You cannot evaluate code!", color: @warning_color))
    else
      [head | _tail] = String.split(msg.content(), " ")
      try do
        {result, _bindings} = msg.content()
                              |> String.slice(String.length(head)..String.length(msg.content()))
                              |> Code.eval_string([msg: msg], __ENV__)
        embed = embed(msg, description: "Execution succeeded! Here's the result:\n```#{inspect result}```",
            footer: "Elixir Code evaluated by #{msg.author().username()}\##{msg.author().discriminator()}")
        Api.create_message!(msg.channel_id(), embed: embed)
      rescue
        e ->
          embed = embed(msg, description: "**An error occurred:** #{e.message}", footer: "Please report this bug to the developers.",
            color: @error_color)
          Api.create_message(msg.channel_id(), embed: embed)
      catch
        e ->
          embed = embed(msg, description: "**An error occurred:** #{e.message}", footer: "Please report this bug to the developers.",
            color: @error_color)
          Api.create_message(msg.channel_id(), embed: embed)
      end
    end
  end

  defp embed(msg, opts) do
    alias Nostrum.Struct.User
    import Nostrum.Struct.Embed

    %Nostrum.Struct.Embed {}
    |> put_description(opts[:description])
    |> put_footer(opts[:footer] || "Requested by #{msg.author().username()}\##{msg.author().discriminator()}" , User.avatar_url(msg.author()))
    |> put_color(opts[:color] || @bot_color)
    |> put_timestamp(DateTime.utc_now() |> DateTime.to_iso8601())
  end
end