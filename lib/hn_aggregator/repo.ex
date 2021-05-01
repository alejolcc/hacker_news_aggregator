defmodule HnAggregator.Repo do
  @moduledoc """
  Module use as Repository of stories

  On this case in particular we can handle the data with a simple gen_server
  because the data its no so big.
  In the case that we need more complex operations over the Repo or if we have to handle
  big amounts of data an ETS is prefered.

  With this implementation all the operation are O(n) complexity.
  With an ETS we can use the id as key and use 'term_to_binary' to store maps
  this way we can lookup with a complexity of O(1)
  """

  @name __MODULE__

  use GenServer

  @type story :: map()

  #
  # API
  #

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: @name)
  end

  @doc """
  Push new stories to the store.
  """
  @spec push_stories([story()]) :: :ok
  def push_stories(stories) do
    GenServer.cast(@name, {:push, stories})
  end

  @doc """
  Get an story by its id
  """
  @spec get_story(integer()) :: story()
  def get_story(id) do
    GenServer.call(@name, {:lookup, id})
  end

  @doc """
  Get all stories from the store
  """
  @spec get_stories :: [story()]
  def get_stories do
    GenServer.call(@name, :get)
  end

  @doc """
  Get the first N stories from the store
  """
  @spec get_stories(integer()) :: [story()]
  def get_stories(n) do
    GenServer.call(@name, {:get, n})
  end

  # Callbacks

  @impl true
  def init(_opts) do
    state = %{
      stories: []
    }

    {:ok, state}
  end

  @impl true
  def handle_cast({:push, stories}, state) do
    {:noreply, %{state | stories: stories}}
  end

  @impl true
  def handle_call({:lookup, id}, _from, state) do
    story =
      Enum.find(state.stories, fn s ->
        s["id"] == id
      end)

    {:reply, story, state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state.stories, state}
  end

  @impl true
  def handle_call({:get, n}, _from, state) do
    stories = Enum.take(state.stories, n)
    {:reply, stories, state}
  end
end
