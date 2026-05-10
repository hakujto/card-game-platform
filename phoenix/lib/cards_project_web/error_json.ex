defmodule CardsProjectWeb.ErrorJSON do
  def render("404.json", _assigns), do: %{error: "Not found"}
  def render("422.json", _assigns), do: %{error: "Unprocessable entity"}
  def render(_template, _assigns), do: %{error: "Internal server error"}
end
