defmodule HnAggregator.Stories do
  @moduledoc """
  The Stories context
  """

  alias HnAggregator.Repo

  @type story :: map()

  @stories_topic "stories"

  @spec push_stories([map]) :: :ok
  def push_stories(stories) do
    Repo.push_stories(stories)
    broadcast()
    :ok
  end

  @spec list_stories :: [story]
  def list_stories, do: Repo.get_stories()

  @spec list_paginated_stories(integer(), integer()) :: {:error, :bad_params} | {:ok, [story]}
  def list_paginated_stories(page, limit) when page > 0 and limit > 0 do
    stories = Repo.get_stories_paginated(page, limit)
    {:ok, stories}
  end

  def list_paginated_stories(_, _) do
    {:error, :bad_params}
  end

  @spec get_story(integer) :: story
  def get_story(id), do: Repo.get_story(id)

  @spec subscribe() :: :ok | {:error, term()}
  def subscribe do
    Phoenix.PubSub.subscribe(HnAggregator.PubSub, @stories_topic)
  end

  defp broadcast do
    Phoenix.PubSub.broadcast(HnAggregator.PubSub, @stories_topic, :new_stories)
  end
end
