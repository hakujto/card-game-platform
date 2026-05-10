defmodule CardsProject.Repo do
  use Ecto.Repo,
    otp_app: :cards_project,
    adapter: Ecto.Adapters.SQLite3
end
