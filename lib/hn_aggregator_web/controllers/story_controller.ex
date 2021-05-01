defmodule HnAggregatorWeb.StoryController do
  use HnAggregatorWeb, :controller

  alias HnAggregator.Repo

  def index(conn, %{"page" => page}) do
    {page, _} = Integer.parse(page)
    stories = Repo.get_stories(page)

    json(conn, stories)
  end

  def get(conn, %{"id" => id}) do
    {id, _} = Integer.parse(id)
    story = Repo.get_story(id)
    json(conn, story)
  end
end
