defmodule CardsProjectWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
      import Phoenix.ConnTest

      alias CardsProject.Repo

      @endpoint CardsProject.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CardsProject.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CardsProject.Repo, {:shared, self()})
    end

    %{conn: Phoenix.ConnTest.build_conn()}
  end
end
