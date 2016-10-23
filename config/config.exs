# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :rockstar_dev,
  ecto_repos: [RockstarDev.Repo]

# Configures the endpoint
config :rockstar_dev, RockstarDev.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Tfq9+UreNjQcREBx4HKgTxDX/ZyZtjMeP3fcAj2xbdtshayk3e1wNo5FueLBRKUm",
  render_errors: [view: RockstarDev.ErrorView, accepts: ~w(html json)],
  pubsub: [name: RockstarDev.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :rockstar_dev, GitHub,
  client_id: System.get_env("GITHUB_ID"),
  client_secret: System.get_env("GITHUB_SECRET"),
  token: System.get_env("GITHUB_TOKEN")

# config :quantum, cron: [
#   "* * * * *": {RockstarDev.GitHub, :cron}
# ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
