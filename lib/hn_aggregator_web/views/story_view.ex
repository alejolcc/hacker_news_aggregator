defmodule HnAggregatorWeb.StoryView do
  use HnAggregatorWeb, :view

  def render("index.json", %{stories: stories}) do
    %{stories: stories}
  end

  def render("show.json", %{stories: stories}) do
    %{stories: stories}
  end

  def render("400.json", %{message: message}) do
    %{error: message}
  end
end
