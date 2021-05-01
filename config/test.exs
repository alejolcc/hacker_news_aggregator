use Mix.Config

config :hn_aggregator, HnAggregator.WebClient,
  url: "http://localhost:9999",
  timeout: :timer.seconds(5)

config :hn_aggregator, HnAggregator.Poller,
  interval: :timer.minutes(5),
  quantity: 50

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :hn_aggregator, HnAggregatorWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
