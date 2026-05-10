defmodule CardsProject.Players do
  @moduledoc """
  The Players BC context.
  """

  import Ecto.Query, warn: false
  alias CardsProject.Repo

  alias CardsProject.Players.Player
  alias CardsProject.Players.PlayerSeasonStats
  alias CardsProject.Players.PlayerCollection
  alias CardsProject.Players.Friendship
  alias CardsProject.Players.Achievement
  alias CardsProject.Players.PlayerAchievement
  alias CardsProject.Players.CraftingRecipe
  alias CardsProject.Players.CraftingIngredient

  # ── Player ─────────────────────────────────────────────────────

  def list_players, do: Repo.all(Player)

  def get_player!(id), do: Repo.get!(Player, id)

  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  def delete_player(%Player{} = player), do: Repo.delete(player)

  def change_player(%Player{} = player, attrs \\ %{}) do
    Player.changeset(player, attrs)
  end

  # ── PlayerSeasonStats ─────────────────────────────────────────────────────

  def list_player_season_statses, do: Repo.all(PlayerSeasonStats)

  def get_player_season_stats!(id), do: Repo.get!(PlayerSeasonStats, id)

  def create_player_season_stats(attrs \\ %{}) do
    %PlayerSeasonStats{}
    |> PlayerSeasonStats.changeset(attrs)
    |> Repo.insert()
  end

  def update_player_season_stats(%PlayerSeasonStats{} = player_season_stats, attrs) do
    player_season_stats
    |> PlayerSeasonStats.changeset(attrs)
    |> Repo.update()
  end

  def delete_player_season_stats(%PlayerSeasonStats{} = player_season_stats), do: Repo.delete(player_season_stats)

  def change_player_season_stats(%PlayerSeasonStats{} = player_season_stats, attrs \\ %{}) do
    PlayerSeasonStats.changeset(player_season_stats, attrs)
  end

  # ── PlayerCollection ─────────────────────────────────────────────────────

  def list_player_collections, do: Repo.all(PlayerCollection)

  def get_player_collection!(id), do: Repo.get!(PlayerCollection, id)

  def create_player_collection(attrs \\ %{}) do
    %PlayerCollection{}
    |> PlayerCollection.changeset(attrs)
    |> Repo.insert()
  end

  def update_player_collection(%PlayerCollection{} = player_collection, attrs) do
    player_collection
    |> PlayerCollection.changeset(attrs)
    |> Repo.update()
  end

  def delete_player_collection(%PlayerCollection{} = player_collection), do: Repo.delete(player_collection)

  def change_player_collection(%PlayerCollection{} = player_collection, attrs \\ %{}) do
    PlayerCollection.changeset(player_collection, attrs)
  end

  # ── Friendship ─────────────────────────────────────────────────────

  def list_friendships, do: Repo.all(Friendship)

  def get_friendship!(id), do: Repo.get!(Friendship, id)

  def create_friendship(attrs \\ %{}) do
    %Friendship{}
    |> Friendship.changeset(attrs)
    |> Repo.insert()
  end

  def update_friendship(%Friendship{} = friendship, attrs) do
    friendship
    |> Friendship.changeset(attrs)
    |> Repo.update()
  end

  def delete_friendship(%Friendship{} = friendship), do: Repo.delete(friendship)

  def change_friendship(%Friendship{} = friendship, attrs \\ %{}) do
    Friendship.changeset(friendship, attrs)
  end

  # ── Achievement ─────────────────────────────────────────────────────

  def list_achievements, do: Repo.all(Achievement)

  def get_achievement!(id), do: Repo.get!(Achievement, id)

  def create_achievement(attrs \\ %{}) do
    %Achievement{}
    |> Achievement.changeset(attrs)
    |> Repo.insert()
  end

  def update_achievement(%Achievement{} = achievement, attrs) do
    achievement
    |> Achievement.changeset(attrs)
    |> Repo.update()
  end

  def delete_achievement(%Achievement{} = achievement), do: Repo.delete(achievement)

  def change_achievement(%Achievement{} = achievement, attrs \\ %{}) do
    Achievement.changeset(achievement, attrs)
  end

  # ── PlayerAchievement ─────────────────────────────────────────────────────

  def list_player_achievements, do: Repo.all(PlayerAchievement)

  def get_player_achievement!(id), do: Repo.get!(PlayerAchievement, id)

  def create_player_achievement(attrs \\ %{}) do
    %PlayerAchievement{}
    |> PlayerAchievement.changeset(attrs)
    |> Repo.insert()
  end

  def update_player_achievement(%PlayerAchievement{} = player_achievement, attrs) do
    player_achievement
    |> PlayerAchievement.changeset(attrs)
    |> Repo.update()
  end

  def delete_player_achievement(%PlayerAchievement{} = player_achievement), do: Repo.delete(player_achievement)

  def change_player_achievement(%PlayerAchievement{} = player_achievement, attrs \\ %{}) do
    PlayerAchievement.changeset(player_achievement, attrs)
  end

  # ── CraftingRecipe ─────────────────────────────────────────────────────

  def list_crafting_recipes, do: Repo.all(CraftingRecipe)

  def get_crafting_recipe!(id), do: Repo.get!(CraftingRecipe, id)

  def create_crafting_recipe(attrs \\ %{}) do
    %CraftingRecipe{}
    |> CraftingRecipe.changeset(attrs)
    |> Repo.insert()
  end

  def update_crafting_recipe(%CraftingRecipe{} = crafting_recipe, attrs) do
    crafting_recipe
    |> CraftingRecipe.changeset(attrs)
    |> Repo.update()
  end

  def delete_crafting_recipe(%CraftingRecipe{} = crafting_recipe), do: Repo.delete(crafting_recipe)

  def change_crafting_recipe(%CraftingRecipe{} = crafting_recipe, attrs \\ %{}) do
    CraftingRecipe.changeset(crafting_recipe, attrs)
  end

  # ── CraftingIngredient ─────────────────────────────────────────────────────

  def list_crafting_ingredients, do: Repo.all(CraftingIngredient)

  def get_crafting_ingredient!(id), do: Repo.get!(CraftingIngredient, id)

  def create_crafting_ingredient(attrs \\ %{}) do
    %CraftingIngredient{}
    |> CraftingIngredient.changeset(attrs)
    |> Repo.insert()
  end

  def update_crafting_ingredient(%CraftingIngredient{} = crafting_ingredient, attrs) do
    crafting_ingredient
    |> CraftingIngredient.changeset(attrs)
    |> Repo.update()
  end

  def delete_crafting_ingredient(%CraftingIngredient{} = crafting_ingredient), do: Repo.delete(crafting_ingredient)

  def change_crafting_ingredient(%CraftingIngredient{} = crafting_ingredient, attrs \\ %{}) do
    CraftingIngredient.changeset(crafting_ingredient, attrs)
  end

end
