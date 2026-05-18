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

  def player_promote_behavior(id) do
    player = Repo.get!(Player, id)
    result = Player.promote(player)
    Repo.update!(Player.changeset(player, %{}))
    result
  end

  def player_demote_behavior(id) do
    player = Repo.get!(Player, id)
    result = Player.demote(player)
    Repo.update!(Player.changeset(player, %{}))
    result
  end

  def player_record_win_behavior(id) do
    player = Repo.get!(Player, id)
    Player.record_win(player)
    Repo.update!(Player.changeset(player, %{}))
  end

  def player_record_loss_behavior(id) do
    player = Repo.get!(Player, id)
    Player.record_loss(player)
    Repo.update!(Player.changeset(player, %{}))
  end

  def player_win_rate_behavior(id) do
    player = Repo.get!(Player, id)
    result = Player.win_rate(player)
    Repo.update!(Player.changeset(player, %{}))
    result
  end

  def player_verify_behavior(id) do
    player = Repo.get!(Player, id)
    Player.verify(player)
    Repo.update!(Player.changeset(player, %{}))
  end

  def player_update_rating_behavior(id, delta) do
    player = Repo.get!(Player, id)
    Player.update_rating(player, delta)
    Repo.update!(Player.changeset(player, %{}))
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

  def player_season_stats_win_rate_behavior(id) do
    player_season_stats = Repo.get!(PlayerSeasonStats, id)
    result = PlayerSeasonStats.win_rate(player_season_stats)
    Repo.update!(PlayerSeasonStats.changeset(player_season_stats, %{}))
    result
  end

  def player_season_stats_add_points_behavior(id, points) do
    player_season_stats = Repo.get!(PlayerSeasonStats, id)
    PlayerSeasonStats.add_points(player_season_stats, points)
    Repo.update!(PlayerSeasonStats.changeset(player_season_stats, %{}))
  end

  def player_season_stats_record_tournament_win_behavior(id) do
    player_season_stats = Repo.get!(PlayerSeasonStats, id)
    PlayerSeasonStats.record_tournament_win(player_season_stats)
    Repo.update!(PlayerSeasonStats.changeset(player_season_stats, %{}))
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

  def player_collection_add_behavior(id, quantity) do
    player_collection = Repo.get!(PlayerCollection, id)
    PlayerCollection.add(player_collection, quantity)
    Repo.update!(PlayerCollection.changeset(player_collection, %{}))
  end

  def player_collection_remove_behavior(id, quantity) do
    player_collection = Repo.get!(PlayerCollection, id)
    PlayerCollection.remove(player_collection, quantity)
    Repo.update!(PlayerCollection.changeset(player_collection, %{}))
  end

  def player_collection_estimated_value_behavior(id) do
    player_collection = Repo.get!(PlayerCollection, id)
    result = PlayerCollection.estimated_value(player_collection)
    Repo.update!(PlayerCollection.changeset(player_collection, %{}))
    result
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

  def friendship_accept_behavior(id) do
    friendship = Repo.get!(Friendship, id)
    Friendship.accept(friendship)
    Repo.update!(Friendship.changeset(friendship, %{}))
  end

  def friendship_decline_behavior(id) do
    friendship = Repo.get!(Friendship, id)
    Friendship.decline(friendship)
    Repo.update!(Friendship.changeset(friendship, %{}))
  end

  def friendship_block_behavior(id) do
    friendship = Repo.get!(Friendship, id)
    Friendship.block(friendship)
    Repo.update!(Friendship.changeset(friendship, %{}))
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

  def achievement_point_value_behavior(id, multiplier) do
    achievement = Repo.get!(Achievement, id)
    result = Achievement.point_value(achievement, multiplier)
    Repo.update!(Achievement.changeset(achievement, %{}))
    result
  end

  def achievement_reveal_behavior(id) do
    achievement = Repo.get!(Achievement, id)
    Achievement.reveal(achievement)
    Repo.update!(Achievement.changeset(achievement, %{}))
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

  def player_achievement_increment_progress_behavior(id, amount) do
    player_achievement = Repo.get!(PlayerAchievement, id)
    PlayerAchievement.increment_progress(player_achievement, amount)
    Repo.update!(PlayerAchievement.changeset(player_achievement, %{}))
  end

  def player_achievement_complete_behavior(id) do
    player_achievement = Repo.get!(PlayerAchievement, id)
    PlayerAchievement.complete(player_achievement)
    Repo.update!(PlayerAchievement.changeset(player_achievement, %{}))
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

  def crafting_recipe_can_craft_behavior(id, player_id) do
    crafting_recipe = Repo.get!(CraftingRecipe, id)
    result = CraftingRecipe.can_craft(crafting_recipe, player_id)
    Repo.update!(CraftingRecipe.changeset(crafting_recipe, %{}))
    result
  end

  def crafting_recipe_execute_craft_behavior(id, player_id) do
    crafting_recipe = Repo.get!(CraftingRecipe, id)
    CraftingRecipe.execute_craft(crafting_recipe, player_id)
    Repo.update!(CraftingRecipe.changeset(crafting_recipe, %{}))
  end

  def crafting_recipe_disable_behavior(id) do
    crafting_recipe = Repo.get!(CraftingRecipe, id)
    CraftingRecipe.disable(crafting_recipe)
    Repo.update!(CraftingRecipe.changeset(crafting_recipe, %{}))
  end

  def crafting_recipe_enable_behavior(id) do
    crafting_recipe = Repo.get!(CraftingRecipe, id)
    CraftingRecipe.enable(crafting_recipe)
    Repo.update!(CraftingRecipe.changeset(crafting_recipe, %{}))
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
