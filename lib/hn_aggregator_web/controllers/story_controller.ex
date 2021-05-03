defmodule HnAggregatorWeb.StoryController do
  use HnAggregatorWeb, :controller

  alias HnAggregator.Stories

  def index(conn, %{"page" => page} = params) do
    limit =
      (params["limit"] || "10")
      |> safe_parse()

    page = safe_parse(page)

    response =
      case Stories.list_paginated_stories(page, limit) do
        {:error, :bad_params} ->
          %{code: 400, message: "Invalid params"}

        {:ok, stories} ->
          %{code: 200, stories: stories}
      end

    json(conn, response)
  end

  def index(conn, _params) do
    response = Stories.list_stories()
    json(conn, %{status: 200, stories: response})
  end

  def get(conn, %{"id" => id}) do
    id = safe_parse(id)
    story = Stories.get_story(id)
    json(conn, %{status: 200, stories: story})
  end

  defp safe_parse(arg) do
    case Integer.parse(arg) do
      {integer, _} -> integer
      :error -> -1
    end
  end
end
