# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :hn_aggregator, HnAggregatorWeb.Endpoint,
  url: [host: "localhost"],
  http: [
    port: 4000,
    dispatch: [
      {:_,
       [
         {"/ws/stories", HnAggregatorWeb.SocketHandler, []},
         {:_, Phoenix.Endpoint.Cowboy2Handler, {HnAggregatorWeb.Endpoint, []}}
       ]}
    ]
  ],
  secret_key_base: "0cE67mlZ5+stWWqli/CSb7ChpVxgF8isYK9WsCl5gqmRt2SQLZyrRZPwH4ZLjEgz",
  render_errors: [view: HnAggregatorWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: HnAggregator.PubSub,
  live_view: [signing_salt: "G5aBx78B"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
