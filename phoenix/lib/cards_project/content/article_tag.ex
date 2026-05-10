defmodule CardsProject.Content.ArticleTag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "article_tags" do
    field :name, :string
    field :slug, :string

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
  end
end
