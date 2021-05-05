import Config

if config_env() == :prod do
  config :hn_aggregator, HnAggregator.WebClient,
    url: "https://hacker-news.firebaseio.com",
    timeout: :timer.seconds(15)

  config :hn_aggregator, HnAggregator.Poller,
    interval: :timer.minutes(5),
    quantity: 50

  # Configures the endpoint
  secret_key_base =
    System.fetch_env!("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :hn_aggregator, HnAggregatorWeb.Endpoint,
    http: [
      port: System.fetch_env!("WEB_HTTP_PORT") |> String.to_integer(),
      dispatch: [
        {:_,
         [
           {"/ws/stories", HnAggregatorWeb.SocketHandler, []},
           {:_, Phoenix.Endpoint.Cowboy2Handler, {HnAggregatorWeb.Endpoint, []}}
         ]}
      ]
    ],
    url: [host: System.get_env("WEB_HTTP_HOST") || "localhost"],
    ssl: false,
    pubsub_server: HnAggregator.PubSub,
    live_view: [signing_salt: "G5aBx78B"],
    render_errors: [view: HnAggregatorWeb.ErrorView, accepts: ~w(html json), layout: false],
    check_origin: false,
    server: true,
    secret_key_base: secret_key_base,
    transport_options: [socket_opts: [:inet6]],
    cache_static_manifest: "priv/static/cache_manifest.json"

  # Configures Elixir's Logger
  config :logger, :console,
    format: "$time $metadata[$level] $message\n",
    metadata: [:request_id]

  # Use Jason for JSON parsing in Phoenix
  config :phoenix, :json_library, Jason

  config :logger, level: :info
end
