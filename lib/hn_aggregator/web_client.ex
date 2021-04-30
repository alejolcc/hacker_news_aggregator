defmodule HnAggregator.WebClient do
  @moduledoc """
  Hacker News Web API Client

  Module that wrap the HTTP API of Hacker News

  In order to complete the excercise we only implements the basic GET calls
  needed for the aggregator in a simple way
  """

  @name __MODULE__
  @default_timeout Application.compile_env(
                     :hn_aggregator,
                     [HnAggregatorWeb.WebClient, :timeout],
                     :timer.seconds(30)
                   )

  def get_stories(opts \\ []) do
    endpoint = endpoint("/v0/topstories.json")
    timeout = Keyword.get(opts, :timeout, @default_timeout)

    do_request(endpoint, timeout)
  end

  def get_item(id, opts \\ []) do
    endpoint = endpoint("/v0/item/#{id}.json")
    timeout = Keyword.get(opts, :timeout, @default_timeout)

    do_request(endpoint, timeout)
  end

  defp endpoint(call) do
    url =
      :hn_aggregator
      |> Application.get_env(HnAggregatorWeb.WebClient)
      |> Keyword.fetch!(:url)

    url <> call
  end

  defp do_request(endpoint, timeout) do
    Finch.build(:get, endpoint)
    |> Finch.request(@name, receive_timeout: timeout)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        Jason.decode(body)

      {:error, _reason} = err ->
        err
    end
  end
end
