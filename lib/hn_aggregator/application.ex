defmodule HnAggregator.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    poller_config = Application.get_env(:hn_aggregator, HnAggregator.Poller, [])

    children = [
      {Phoenix.PubSub, name: HnAggregator.PubSub},
      HnAggregatorWeb.Endpoint,
      {Finch, name: HnAggregator.WebClient},
      {HnAggregator.Repo, []},
      {HnAggregator.Poller, poller_config}
    ]

    opts = [strategy: :one_for_one, name: HnAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    HnAggregatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
