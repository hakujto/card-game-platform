import Config

config :cards_project, CardsProject.Repo,
  database: "db/cards_project_dev.db"

config :cards_project, CardsProject.Endpoint,
  debug_errors: true,
  code_reloader: false

config :logger, :console, format: "[$level] $message\n"
