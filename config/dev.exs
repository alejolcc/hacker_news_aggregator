use Mix.Config

config :hn_aggregator, HnAggregator.WebClient,
  url: "https://hacker-news.firebaseio.com",
  timeout: :timer.seconds(15)

config :hn_aggregator, HnAggregator.Poller,
  interval: :timer.minutes(5),
  quantity: 50

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :hn_aggregator, HnAggregatorWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
