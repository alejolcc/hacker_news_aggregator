defmodule HnAggregatorWeb.StoryController do
  use HnAggregatorWeb, :controller

  alias HnAggregator.Stories

  def index(conn, %{"page" => page} = params) do
    limit =
      (params["limit"] || "10")
      |> safe_parse()

    page = safe_parse(page)

    case Stories.list_paginated_stories(page, limit) do
      {:error, :bad_params} ->
        conn
        |> put_status(400)
        |> render("400.json", message: "Invalid Params")

      {:ok, stories} ->
        conn
        |> put_status(200)
        |> render("index.json", stories: stories)
    end
  end

  def index(conn, _params) do
    response = Stories.list_stories()

    conn
    |> put_status(200)
    |> render("index.json", stories: response)
  end

  def get(conn, %{"id" => id}) do
    story =
      id
      |> safe_parse()
      |> Stories.get_story()

    conn
    |> put_status(200)
    |> render("show.json", stories: story)
  end

  defp safe_parse(arg) do
    case Integer.parse(arg) do
      {integer, _} -> integer
      :error -> -1
    end
  end
end
