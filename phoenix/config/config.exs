import Config

config :cards_project, CardsProject.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: "db/cards_project_dev.db"

config :cards_project, CardsProject.Endpoint,
  url: [host: "localhost"],
  http: [ip: {127, 0, 0, 1}, port: 4000],
  secret_key_base: "changeme_at_least_64_chars_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  render_errors: [
    formats: [json: CardsProjectWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CardsProject.PubSub

config :cards_project, ecto_repos: [CardsProject.Repo]

config :logger, :console,
  format: "\$time \$metadata[\$level] \$message\n",
  metadata: [:request_id]
