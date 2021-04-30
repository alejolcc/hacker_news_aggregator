defmodule HnAggregator.WebClient do
  @moduledoc """
  Hacker News Web API Client

  Module that wrap the HTTP API of Hacker News

  In order to complete the excercise we only implements the basic GET calls
  needed for the aggregator in a simple way
  """

  @name __MODULE__
  @endpoint "https://hacker-news.firebaseio.com"
  @default_timeout :timer.seconds(30)

  def get_stories() do
    endpoint = @endpoint <> "/v0/topstories.json"
    timeout = @default_timeout
    do_request(endpoint, timeout)
  end

  def get_item(id) do
    endpoint = @endpoint <> "/v0/item/#{id}.json"
    timeout = @default_timeout
    do_request(endpoint, timeout)
  end

  defp do_request(endpoint, timeout) do
    Finch.build(:get, endpoint)
    |> Finch.request(@name, receive_timeout: timeout)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        Jason.decode(body)
        |> IO.inspect()

      {:error, _reason} = err ->
        err
    end
  end
end
