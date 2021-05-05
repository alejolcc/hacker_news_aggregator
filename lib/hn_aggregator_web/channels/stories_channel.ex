defmodule HnAggregatorWeb.StoriesChannel do
  @moduledoc """
  Channel controller.

  Implement the API over phoenix channels
  """
  use HnAggregatorWeb, :channel

  alias HnAggregator.Stories

  require Logger

  @impl true
  def join("stories:feed", _payload, socket) do
    Stories.subscribe()
    Process.send(self(), :new_stories, [])
    {:ok, socket}
  end

  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in(event, payload, socket) do
    Logger.warn("Unhandle event #{event} with payload #{inspect(payload)}")
    {:noreply, socket}
  end

  @impl true
  def handle_info(:new_stories, socket) do
    payload = Stories.list_stories()

    push(socket, "new stories", %{stories: payload})
    {:noreply, socket}
  end
end
