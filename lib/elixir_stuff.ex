defmodule ElixirStuff do
  defmodule Commands do
    use GenServer

    def start_link(opts), do: GenServer.start_link(__MODULE__, :ok, opts)
    def fetch(server, name), do: GenServer.call(server, {:fetch, name}, 1000)
    def create(server, name, handler), do: GenServer.cast(server, {:create, name, handler})
    def execute(server, name, context), do: GenServer.cast(server, {:execute, name, context})

    def init(:ok), do: {:ok, %{}}
    def handle_call({:fetch, name}, _from, cmds), do: {:reply, Map.fetch(cmds, name), cmds}
    def handle_cast({:create, name, handler}, cmds), do: {:noreply, Map.put(cmds, name, handler)}
    def handle_cast({:execute, name, context}, cmds) do
      spawn fn() -> (Map.fetch(cmds, name) |> elem(1)).(context) end
      {:noreply, cmds}
    end
  end

  use Nostrum.Consumer
  alias Nostrum.Api

  def start_link do
    {:ok, _pid} = Commands.start_link(name: Commands.Worker)
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, {_}, _ws_state}) do
    register_command("ping", fn({msg}) -> Api.create_message(msg.channel_id(), "Pong!") end)
    register_command("hello", fn({msg}) -> Api.create_message(msg.channel_id(), "Hello world!") end)
  end

  def handle_event({:MESSAGE_CREATE, {msg}, _ws_state}) do
    unless !String.starts_with?(msg.content(), "!") do
      [head | _] = String.split(msg.content(), " ")
      got = Commands.fetch(Commands.Worker, head)
      if (got != :error) do
        Commands.execute(Commands.Worker, head, {msg})
      else
      end
    end
  end

  def handle_event(_event), do: :noop
  def register_command(name, handler), do: Commands.create(Commands.Worker, "!#{name}", handler)
end
