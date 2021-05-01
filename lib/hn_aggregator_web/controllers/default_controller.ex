defmodule HnAggregatorWeb.DefaultController do
  use HnAggregatorWeb, :controller

  def index(conn, _params) do
    text(conn, "Hacker News!")
  end
end
