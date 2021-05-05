defmodule HnAggregator.Repo do
  @moduledoc """
  Module use as Repository of stories

  Is a wrap over an ordered_set ets.
  In order to mantain the same order than HN web page we use an autoincremental index,
  this way, the id 1 correspond to the first story in the hacker news page (https://news.ycombinator.com/)

  Take note that getting the stories by is firebase id could be easily implemented
  adding that id in the tuple when you push the data
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
  Push the list of `stories` to the repo giving an auto generated id
  """
  @spec push_stories([story()]) :: :ok
  def push_stories(stories) do
    GenServer.call(@name, {:push, stories})
  end

  @doc """
  Return an story by its `id`
  """
  @spec get_story(integer()) :: story()
  def get_story(id) do
    case :ets.lookup(@table_name, id) do
      [{_id, story}] -> story
      [] -> nil
    end
  end

  @doc """
  Return all stories
  """
  @spec get_stories :: [story()]
  def get_stories do
    :ets.select(@table_name, [{{:"$1", :"$2"}, [], [:"$2"]}])
  end

  @doc """
  Return the first `n` stories
  """
  @spec get_stories(integer()) :: [story()]
  def get_stories(n) do
    {stories, _} = :ets.select(@table_name, [{{:"$1", :"$2"}, [], [:"$2"]}], n)
    stories
  end

  @doc """
  Return an `amount` number of stories corresponding to a `page` number
  """
  @spec get_stories_paginated(integer(), integer()) :: list
  def get_stories_paginated(page, amount)

  def get_stories_paginated(1, amount) do
    case :ets.select(@table_name, [{{:"$1", :"$2"}, [], [:"$2"]}], amount) do
      :"$end_of_table" -> []
      {stories, _ref} -> stories
    end
  end

  def get_stories_paginated(page, amount) when page > 1 do
    case :ets.select(@table_name, [{{:"$1", :"$2"}, [], [:"$2"]}], amount) do
      :"$end_of_table" -> []
      {stories, :"$end_of_table"} -> stories
      {stories, ref} -> get_chunk(page - 1, ref, stories)
    end
  end

  #
  # Internal functions
  #

  defp get_chunk(1, ref, res) do
    case :ets.select(ref) do
      :"$end_of_table" -> res
      {stories, _} -> stories
    end
  end

  defp get_chunk(page, ref, res) do
    case :ets.select(ref) do
      :"$end_of_table" -> res
      {stories, :"$end_of_table"} -> stories
      {stories, ref} -> get_chunk(page - 1, ref, stories)
    end
  end

  #
  # Callbacks
  #

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
