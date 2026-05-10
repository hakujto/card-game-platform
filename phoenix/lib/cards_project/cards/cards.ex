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
