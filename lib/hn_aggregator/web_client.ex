defmodule HnAggregator.WebClient do
  @moduledoc """
  Hacker News Web API Client

  Module that wrap the all the HTTP API calls needed for the excercise

  All functions accept a `:timeout` option in milliseconds for the
  request.
  """

  @name __MODULE__
  @default_timeout :timer.seconds(30)

  @type response :: list() | map()

  @doc """
  Get top stories

  ## Options

  - `:timeout`: Timeout for the request

  """
  @spec get_stories(Keyword.t()) :: {:ok, response()} | {:error, term()}
  def get_stories(opts \\ []) do
    endpoint = endpoint("/v0/topstories.json")
    timeout = Keyword.get(opts, :timeout, @default_timeout)

    do_request(endpoint, timeout)
  end

  @doc """
  Get an item for the given `id`

  ## Options

  - `:timeout`: Timeout for the request

  """
  @spec get_item(integer(), Keyword.t()) :: {:ok, response()} | {:error, term()}
  def get_item(id, opts \\ []) do
    endpoint = endpoint("/v0/item/#{id}.json")
    timeout = Keyword.get(opts, :timeout, @default_timeout)

    do_request(endpoint, timeout)
  end

  defp endpoint(call) do
    url =
      :hn_aggregator
      |> Application.get_env(HnAggregator.WebClient)
      |> Keyword.fetch!(:url)

    url <> call
  end

  defp do_request(endpoint, timeout) do
    Finch.build(:get, endpoint)
    |> Finch.request(@name, receive_timeout: timeout)
    |> case do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %Finch.Response{status: 401}} ->
        {:error, {:permission_denied, endpoint}}

      {:ok, %Finch.Response{status: status_code}} ->
        {:error, {:error, status_code}}

      {:error, %Mint.TransportError{reason: :timeout}} ->
        {:error, :timeout}

      {:error, _reason} = err ->
        err
    end
  end
end
