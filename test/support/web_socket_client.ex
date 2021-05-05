defmodule HnAggregatorWeb.WebSocketClient do
  @moduledoc """
  Simple Web Socket client for testing porpouses
  """

  @host 'localhost'
  @port 4002
  @path '/ws/stories'

  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(args) do
    test_pid = Keyword.get(args, :test_pid)

    connect_opts = %{
      connect_timeout: :timer.seconds(5)
    }

    with {:ok, gun} <- :gun.open(@host, @port, connect_opts),
         {:ok, protocol} <- :gun.await_up(gun),
         stream <- :gun.ws_upgrade(gun, @path, []) do
      state = %{gun: gun, protocol: protocol, stream: stream, test_pid: test_pid}
      {:ok, state}
    end
  end

  @impl true
  def handle_info({:gun_ws, _pid, _ref, message}, state) do
    Process.send(state.test_pid, {:receive, message}, [])
    {:noreply, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end
end
