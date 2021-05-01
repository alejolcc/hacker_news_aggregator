defmodule HnAggregator.Poller do
  @moduledoc """
  Poller is in charge of the polling task and save to store the HN stories.

  The interval of time to work and the quantity of stories to request
  can be configured from Application enviroments vars
  """

  require Logger

  @name __MODULE__

  use GenServer

  alias HnAggregator.{Repo, WebClient}

  #
  # API
  #

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  #
  # GenServer Callbacks
  #

  @impl true
  def init(opts) do
    interval = Keyword.get(opts, :interval, :timer.minutes(5))
    quantity = Keyword.get(opts, :quantity, 50)

    state = %{
      interval: interval,
      quantity: quantity
    }

    {:ok, state, {:continue, :first_call}}
  end

  @impl true
  def handle_continue(:first_call, state) do
    work(state.quantity)
    schedule_work(state.interval)
    {:noreply, state}
  end

  @impl true
  def handle_info(:work, state) do
    work(state.quantity)
    schedule_work(state.interval)
    {:noreply, state}
  end

  #
  # Internal functions
  #

  defp work(quantity) do
    quantity
    |> get_stories()
    |> Repo.push_stories()
  end

  defp get_stories(n) do
    Logger.info("Requesting top #{n} stories from HN")

    case WebClient.get_stories() do
      {:ok, stories} ->
        stories
        |> Enum.take(n)
        |> Task.async_stream(&get_item/1, orderer: true)
        |> Enum.reduce([], fn
          {:ok, nil}, acc -> acc
          {:ok, item}, acc -> acc ++ [item]
        end)

      err ->
        Logger.error("Can't get stories from Hacker News, reason: #{inspect(err)}")
        []
    end
  end

  defp get_item(item_id) do
    case WebClient.get_item(item_id) do
      {:ok, item} ->
        item

      err ->
        Logger.error(
          "Can't get item #{inspect(item_id)} from Hacker News, reason: #{inspect(err)}"
        )

        nil
    end
  end

  defp schedule_work(time) do
    Process.send_after(self(), :work, time)
  end
end
