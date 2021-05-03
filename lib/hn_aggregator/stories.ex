defmodule HnAggregator.Stories do
  @moduledoc """
  The Stories context
  """

  alias HnAggregator.Repo

  @type story :: map()

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
end
