import Config

config :cards_project, CardsProject.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: "db/cards_project_test.db",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :cards_project, CardsProject.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret_key_base_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  server: false

config :logger, level: :warning
