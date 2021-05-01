defmodule HnAggregator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HnAggregatorWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HnAggregator.PubSub},
      # Start the Endpoint (http/https)
      HnAggregatorWeb.Endpoint,
      {Finch, name: HnAggregator.WebClient},
      {HnAggregator.Repo, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HnAggregator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HnAggregatorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
