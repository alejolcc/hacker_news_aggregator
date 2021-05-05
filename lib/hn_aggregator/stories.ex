defmodule HnAggregator.Stories do
  @moduledoc """
  The Stories context used to decouple Repo calls from the endpoint
  """

  alias HnAggregator.Repo

  @type story :: map()

  @stories_topic "stories"

  @doc """
  Push a list of `stories` into the Repo and send a broadcast message via PubSub
  with the payload `:new_stories` in the topic `"stories"`
  """
  @spec push_stories([map]) :: :ok
  def push_stories(stories) do
    Repo.push_stories(stories)
    broadcast()
    :ok
  end

  @doc """
  Return all stories from the Repo
  """
  @spec list_stories :: [story]
  def list_stories, do: Repo.get_stories()

  @doc """
  Return an `amount` number of stories from the repo corresponding to a `page` number
  or `{:error, :bad_params}` if the params are wrong
  """
  @spec list_paginated_stories(integer(), integer()) :: {:error, :bad_params} | {:ok, [story]}
  def list_paginated_stories(page, amount) when page > 0 and amount > 0 do
    stories = Repo.get_stories_paginated(page, amount)
    {:ok, stories}
  end

  def list_paginated_stories(_, _) do
    {:error, :bad_params}
  end

  @doc """
  Fetches a single story from Repo with key `id`
  """
  @spec get_story(integer) :: story
  def get_story(id), do: Repo.get_story(id)

  @doc """
  Subscribe to topic `"stories"` where the info about updates comes
  """
  @spec subscribe() :: :ok | {:error, term()}
  def subscribe do
    Phoenix.PubSub.subscribe(HnAggregator.PubSub, @stories_topic)
  end

  defp broadcast do
    Phoenix.PubSub.broadcast(HnAggregator.PubSub, @stories_topic, :new_stories)
  end
end
