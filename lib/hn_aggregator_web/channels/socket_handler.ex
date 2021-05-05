defmodule HnAggregatorWeb.SocketHandler do
  @moduledoc """
  Web Socket controller.

  Implement the API over raw web_sockets,
  use the behaviour of cowboy to handle the web_socket protocl
  """

  @behaviour :cowboy_websocket

  alias HnAggregator.Stories

  require Logger

  @impl true
  def init(req, _state) do
    {:cowboy_websocket, req, %{}}
  end

  @impl true
  def websocket_init(state) do
    Stories.subscribe()
    Process.send(self(), :new_stories, [])
    {:ok, state}
  end

  @impl true
  def websocket_handle({_frame_type, _data}, state) do
    {:ok, state}
  end

  @impl true
  def websocket_info(:new_stories, state) do
    payload =
      Stories.list_stories()
      |> Jason.encode!()

    {:reply, {:text, payload}, state}
  end

  @impl true
  def websocket_info(_, state) do
    {:ok, state}
  end
end
