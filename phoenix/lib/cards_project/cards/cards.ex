defmodule CardsProject.Cards do
  @moduledoc """
  The Cards BC context.
  """

  import Ecto.Query, warn: false
  alias CardsProject.Repo

  alias CardsProject.Cards.Card
  alias CardsProject.Cards.CardSet
  alias CardsProject.Cards.CardRuling
  alias CardsProject.Cards.CardAbility
  alias CardsProject.Cards.Deck
  alias CardsProject.Cards.DeckCard
  alias CardsProject.Cards.DeckSideboardCard
  alias CardsProject.Cards.DeckTag
  alias CardsProject.Cards.DeckTagAssignment

  # ── Card ─────────────────────────────────────────────────────

  def list_cards, do: Repo.all(Card)

  def get_card!(id), do: Repo.get!(Card, id)

  def create_card(attrs \\ %{}) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
  end

  def update_card(%Card{} = card, attrs) do
    card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  def delete_card(%Card{} = card), do: Repo.delete(card)

  def change_card(%Card{} = card, attrs \\ %{}) do
    Card.changeset(card, attrs)
  end

  def card_ban_behavior(id) do
    card = Repo.get!(Card, id)
    Card.ban(card)
    Repo.update!(Card.changeset(card, %{}))
  end

  def card_unban_behavior(id) do
    card = Repo.get!(Card, id)
    Card.unban(card)
    Repo.update!(Card.changeset(card, %{}))
  end

  def card_restrict_behavior(id) do
    card = Repo.get!(Card, id)
    Card.restrict(card)
    Repo.update!(Card.changeset(card, %{}))
  end

  def card_unrestrict_behavior(id) do
    card = Repo.get!(Card, id)
    Card.unrestrict(card)
    Repo.update!(Card.changeset(card, %{}))
  end

  def card_calculate_value_behavior(id) do
    card = Repo.get!(Card, id)
    result = Card.calculate_value(card)
    Repo.update!(Card.changeset(card, %{}))
    result
  end

  def card_apply_rarity_bonus_behavior(id, multiplier) do
    card = Repo.get!(Card, id)
    result = Card.apply_rarity_bonus(card, multiplier)
    Repo.update!(Card.changeset(card, %{}))
    result
  end

  def card_is_legal_in_format_behavior(id, format) do
    card = Repo.get!(Card, id)
    result = Card.is_legal_in_format(card, format)
    Repo.update!(Card.changeset(card, %{}))
    result
  end

  # ── CardSet ─────────────────────────────────────────────────────

  def list_card_sets, do: Repo.all(CardSet)

  def get_card_set!(id), do: Repo.get!(CardSet, id)

  def create_card_set(attrs \\ %{}) do
    %CardSet{}
    |> CardSet.changeset(attrs)
    |> Repo.insert()
  end

  def update_card_set(%CardSet{} = card_set, attrs) do
    card_set
    |> CardSet.changeset(attrs)
    |> Repo.update()
  end

  def delete_card_set(%CardSet{} = card_set), do: Repo.delete(card_set)

  def change_card_set(%CardSet{} = card_set, attrs \\ %{}) do
    CardSet.changeset(card_set, attrs)
  end

  def card_set_is_legal_in_standard_behavior(id) do
    card_set = Repo.get!(CardSet, id)
    result = CardSet.is_legal_in_standard(card_set)
    Repo.update!(CardSet.changeset(card_set, %{}))
    result
  end

  def card_set_is_legal_in_format_behavior(id, format) do
    card_set = Repo.get!(CardSet, id)
    result = CardSet.is_legal_in_format(card_set, format)
    Repo.update!(CardSet.changeset(card_set, %{}))
    result
  end

  def card_set_card_count_by_rarity_behavior(id, rarity) do
    card_set = Repo.get!(CardSet, id)
    result = CardSet.card_count_by_rarity(card_set, rarity)
    Repo.update!(CardSet.changeset(card_set, %{}))
    result
  end

  def card_set_rotate_out_behavior(id) do
    card_set = Repo.get!(CardSet, id)
    CardSet.rotate_out(card_set)
    Repo.update!(CardSet.changeset(card_set, %{}))
  end

  # ── CardRuling ─────────────────────────────────────────────────────

  def list_card_rulings, do: Repo.all(CardRuling)

  def get_card_ruling!(id), do: Repo.get!(CardRuling, id)

  def create_card_ruling(attrs \\ %{}) do
    %CardRuling{}
    |> CardRuling.changeset(attrs)
    |> Repo.insert()
  end

  def update_card_ruling(%CardRuling{} = card_ruling, attrs) do
    card_ruling
    |> CardRuling.changeset(attrs)
    |> Repo.update()
  end

  def delete_card_ruling(%CardRuling{} = card_ruling), do: Repo.delete(card_ruling)

  def change_card_ruling(%CardRuling{} = card_ruling, attrs \\ %{}) do
    CardRuling.changeset(card_ruling, attrs)
  end

  def card_ruling_is_current_behavior(id) do
    card_ruling = Repo.get!(CardRuling, id)
    result = CardRuling.is_current(card_ruling)
    Repo.update!(CardRuling.changeset(card_ruling, %{}))
    result
  end

  def card_ruling_supersedes_previous_behavior(id) do
    card_ruling = Repo.get!(CardRuling, id)
    result = CardRuling.supersedes_previous(card_ruling)
    Repo.update!(CardRuling.changeset(card_ruling, %{}))
    result
  end

  # ── CardAbility ─────────────────────────────────────────────────────

  def list_card_abilities, do: Repo.all(CardAbility)

  def get_card_ability!(id), do: Repo.get!(CardAbility, id)

  def create_card_ability(attrs \\ %{}) do
    %CardAbility{}
    |> CardAbility.changeset(attrs)
    |> Repo.insert()
  end

  def update_card_ability(%CardAbility{} = card_ability, attrs) do
    card_ability
    |> CardAbility.changeset(attrs)
    |> Repo.update()
  end

  def delete_card_ability(%CardAbility{} = card_ability), do: Repo.delete(card_ability)

  def change_card_ability(%CardAbility{} = card_ability, attrs \\ %{}) do
    CardAbility.changeset(card_ability, attrs)
  end

  def card_ability_is_usable_at_behavior(id, timing) do
    card_ability = Repo.get!(CardAbility, id)
    result = CardAbility.is_usable_at(card_ability, timing)
    Repo.update!(CardAbility.changeset(card_ability, %{}))
    result
  end

  def card_ability_describe_behavior(id) do
    card_ability = Repo.get!(CardAbility, id)
    result = CardAbility.describe(card_ability)
    Repo.update!(CardAbility.changeset(card_ability, %{}))
    result
  end

  # ── Deck ─────────────────────────────────────────────────────

  def list_decks, do: Repo.all(Deck)

  def get_deck!(id), do: Repo.get!(Deck, id)

  def create_deck(attrs \\ %{}) do
    %Deck{}
    |> Deck.changeset(attrs)
    |> Repo.insert()
  end

  def update_deck(%Deck{} = deck, attrs) do
    deck
    |> Deck.changeset(attrs)
    |> Repo.update()
  end

  def delete_deck(%Deck{} = deck), do: Repo.delete(deck)

  def change_deck(%Deck{} = deck, attrs \\ %{}) do
    Deck.changeset(deck, attrs)
  end

  def deck_validate_size_behavior(id) do
    deck = Repo.get!(Deck, id)
    result = Deck.validate_size(deck)
    Repo.update!(Deck.changeset(deck, %{}))
    result
  end

  def deck_add_card_behavior(id, card_id, quantity) do
    deck = Repo.get!(Deck, id)
    Deck.add_card(deck, card_id, quantity)
    Repo.update!(Deck.changeset(deck, %{}))
  end

  def deck_remove_card_behavior(id, card_id) do
    deck = Repo.get!(Deck, id)
    Deck.remove_card(deck, card_id)
    Repo.update!(Deck.changeset(deck, %{}))
  end

  def deck_win_rate_behavior(id) do
    deck = Repo.get!(Deck, id)
    result = Deck.win_rate(deck)
    Repo.update!(Deck.changeset(deck, %{}))
    result
  end

  def deck_clone_behavior(id) do
    deck = Repo.get!(Deck, id)
    result = Deck.clone(deck)
    Repo.update!(Deck.changeset(deck, %{}))
    result
  end

  def deck_publish_behavior(id) do
    deck = Repo.get!(Deck, id)
    Deck.publish(deck)
    Repo.update!(Deck.changeset(deck, %{}))
  end

  def deck_unpublish_behavior(id) do
    deck = Repo.get!(Deck, id)
    Deck.unpublish(deck)
    Repo.update!(Deck.changeset(deck, %{}))
  end

  def deck_certify_tournament_legal_behavior(id) do
    deck = Repo.get!(Deck, id)
    result = Deck.certify_tournament_legal(deck)
    Repo.update!(Deck.changeset(deck, %{}))
    result
  end

  # ── DeckCard ─────────────────────────────────────────────────────

  def list_deck_cards, do: Repo.all(DeckCard)

  def get_deck_card!(id), do: Repo.get!(DeckCard, id)

  def create_deck_card(attrs \\ %{}) do
    %DeckCard{}
    |> DeckCard.changeset(attrs)
    |> Repo.insert()
  end

  def update_deck_card(%DeckCard{} = deck_card, attrs) do
    deck_card
    |> DeckCard.changeset(attrs)
    |> Repo.update()
  end

  def delete_deck_card(%DeckCard{} = deck_card), do: Repo.delete(deck_card)

  def change_deck_card(%DeckCard{} = deck_card, attrs \\ %{}) do
    DeckCard.changeset(deck_card, attrs)
  end

  def deck_card_increment_behavior(id, amount) do
    deck_card = Repo.get!(DeckCard, id)
    DeckCard.increment(deck_card, amount)
    Repo.update!(DeckCard.changeset(deck_card, %{}))
  end

  def deck_card_decrement_behavior(id, amount) do
    deck_card = Repo.get!(DeckCard, id)
    DeckCard.decrement(deck_card, amount)
    Repo.update!(DeckCard.changeset(deck_card, %{}))
  end

  # ── DeckSideboardCard ─────────────────────────────────────────────────────

  def list_deck_sideboard_cards, do: Repo.all(DeckSideboardCard)

  def get_deck_sideboard_card!(id), do: Repo.get!(DeckSideboardCard, id)

  def create_deck_sideboard_card(attrs \\ %{}) do
    %DeckSideboardCard{}
    |> DeckSideboardCard.changeset(attrs)
    |> Repo.insert()
  end

  def update_deck_sideboard_card(%DeckSideboardCard{} = deck_sideboard_card, attrs) do
    deck_sideboard_card
    |> DeckSideboardCard.changeset(attrs)
    |> Repo.update()
  end

  def delete_deck_sideboard_card(%DeckSideboardCard{} = deck_sideboard_card), do: Repo.delete(deck_sideboard_card)

  def change_deck_sideboard_card(%DeckSideboardCard{} = deck_sideboard_card, attrs \\ %{}) do
    DeckSideboardCard.changeset(deck_sideboard_card, attrs)
  end

  def deck_sideboard_card_increment_behavior(id, amount) do
    deck_sideboard_card = Repo.get!(DeckSideboardCard, id)
    DeckSideboardCard.increment(deck_sideboard_card, amount)
    Repo.update!(DeckSideboardCard.changeset(deck_sideboard_card, %{}))
  end

  def deck_sideboard_card_decrement_behavior(id, amount) do
    deck_sideboard_card = Repo.get!(DeckSideboardCard, id)
    DeckSideboardCard.decrement(deck_sideboard_card, amount)
    Repo.update!(DeckSideboardCard.changeset(deck_sideboard_card, %{}))
  end

  # ── DeckTag ─────────────────────────────────────────────────────

  def list_deck_tags, do: Repo.all(DeckTag)

  def get_deck_tag!(id), do: Repo.get!(DeckTag, id)

  def create_deck_tag(attrs \\ %{}) do
    %DeckTag{}
    |> DeckTag.changeset(attrs)
    |> Repo.insert()
  end

  def update_deck_tag(%DeckTag{} = deck_tag, attrs) do
    deck_tag
    |> DeckTag.changeset(attrs)
    |> Repo.update()
  end

  def delete_deck_tag(%DeckTag{} = deck_tag), do: Repo.delete(deck_tag)

  def change_deck_tag(%DeckTag{} = deck_tag, attrs \\ %{}) do
    DeckTag.changeset(deck_tag, attrs)
  end

  def deck_tag_rename_behavior(id, new_name) do
    deck_tag = Repo.get!(DeckTag, id)
    DeckTag.rename(deck_tag, new_name)
    Repo.update!(DeckTag.changeset(deck_tag, %{}))
  end

  def deck_tag_merge_into_behavior(id, target_tag_id) do
    deck_tag = Repo.get!(DeckTag, id)
    DeckTag.merge_into(deck_tag, target_tag_id)
    Repo.update!(DeckTag.changeset(deck_tag, %{}))
  end

  # ── DeckTagAssignment ─────────────────────────────────────────────────────

  def list_deck_tag_assignments, do: Repo.all(DeckTagAssignment)

  def get_deck_tag_assignment!(id), do: Repo.get!(DeckTagAssignment, id)

  def create_deck_tag_assignment(attrs \\ %{}) do
    %DeckTagAssignment{}
    |> DeckTagAssignment.changeset(attrs)
    |> Repo.insert()
  end

  def update_deck_tag_assignment(%DeckTagAssignment{} = deck_tag_assignment, attrs) do
    deck_tag_assignment
    |> DeckTagAssignment.changeset(attrs)
    |> Repo.update()
  end

  def delete_deck_tag_assignment(%DeckTagAssignment{} = deck_tag_assignment), do: Repo.delete(deck_tag_assignment)

  def change_deck_tag_assignment(%DeckTagAssignment{} = deck_tag_assignment, attrs \\ %{}) do
    DeckTagAssignment.changeset(deck_tag_assignment, attrs)
  end

end
