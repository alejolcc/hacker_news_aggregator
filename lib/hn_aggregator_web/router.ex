defmodule HnAggregatorWeb.Router do
  use HnAggregatorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", HnAggregatorWeb do
    pipe_through :api

    get "/stories", StoryController, :index
    get "/stories/:id", StoryController, :get
  end
end
