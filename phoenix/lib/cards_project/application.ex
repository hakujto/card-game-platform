defmodule CardsProject.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CardsProject.Repo,
      CardsProject.Endpoint
    ]

    opts = [strategy: :one_for_one, name: CardsProject.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
