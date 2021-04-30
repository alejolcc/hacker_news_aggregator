defmodule HnAggregator.Poller do
  @moduledoc """
  Poller is in charge of the polling task and save to store of the HN stories
  """

  @name __MODULE__

  use GenServer

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
    polling_time = Keyword.get(opts, :polling_time)

    state = %{
      polling_time: polling_time
    }

    {:ok, state, {:continue, :first_call}}
  end

  @impl true
  def handle_continue(:first_call, state) do
    IO.inspect("primera llamada")
    schedule_work(state.polling_time)
    {:noreply, state}
  end

  @impl true
  def handle_info(:work, state) do
    # Do the desired work here
    IO.inspect("WORK")
    schedule_work(state.polling_time)

    {:noreply, state}
  end

  #
  # Internal functions
  #

  defp schedule_work(time) do
    Process.send_after(self(), :work, time)
  end
end
