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
  @table_name Stories

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
    GenServer.call(@name, {:push, stories})
  end

  @doc """
  Get an story by its id
  """
  @spec get_story(integer()) :: story()
  def get_story(id) do
    case :ets.lookup(@table_name, id) do
      [{_id, story}] -> story
      [] -> nil
    end
  end

  @doc """
  Get all stories from the store
  """
  @spec get_stories :: [story()]
  def get_stories do
    :ets.select(@table_name, [{{:"$1", :"$2"}, [], [:"$2"]}])
  end

  @doc """
  Get the first N stories from the store
  """
  @spec get_stories(integer()) :: [story()]
  def get_stories(n) do
    {stories, _} = :ets.select(@table_name, [{{:"$1", :"$2"}, [], [:"$2"]}], n)
    stories
  end

  # Callbacks

  @impl true
  def init(_opts) do
    :ets.new(@table_name, [:ordered_set, :protected, :named_table])
    index_ref = :counters.new(1, [])

    state = %{
      index_ref: index_ref
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:push, stories}, _from, state) do
    ref = state.index_ref

    # Reset the index
    :counters.put(ref, 1, 0)

    # HN stories ids/times are not sorted,
    # so to mantain the order we have to use an autoincremental id
    # so the orderer_set can use to compare
    Enum.each(stories, fn story ->
      :counters.add(ref, 1, 1)
      index = :counters.get(ref, 1)
      :ets.insert(@table_name, {index, story})
    end)

    {:reply, :ok, state}
  end
end
