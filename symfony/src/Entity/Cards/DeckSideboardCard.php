<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Cards\DeckSideboardCardRepository;

#[ORM\Entity(repositoryClass: DeckSideboardCardRepository::class)]
#[ORM\Table(name: 'deck_sideboard_card')]
class DeckSideboardCard
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['deckSideboardCard:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['deckSideboardCard:read', 'deckSideboardCard:write'])]
    private int $quantity = 1;

    #[ORM\ManyToOne(targetEntity: Deck::class, inversedBy: 'sideboard_cards')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Deck $deck = null;

    #[ORM\ManyToOne(targetEntity: Card::class, inversedBy: 'sideboard_decks')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Card $card = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getQuantity(): int
    {
        return $this->quantity;
    }

    public function setQuantity(int $quantity): static
    {
        $this->quantity = $quantity;
        return $this;
    }

    #[Groups(['deckSideboardCard:read'])]
    public function getDeckId(): ?int
    {
        return $this->deck?->getId();
    }

    public function getDeck(): ?Deck
    {
        return $this->deck;
    }

    public function setDeck(?Deck $deck): static
    {
        $this->deck = $deck;
        return $this;
    }

    #[Groups(['deckSideboardCard:read'])]
    public function getCardId(): ?int
    {
        return $this->card?->getId();
    }

    public function getCard(): ?Card
    {
        return $this->card;
    }

    public function setCard(?Card $card): static
    {
        $this->card = $card;
        return $this;
    }

    // ── Business operations ──────────────────────────────────────────

    public function increment($amount): void
    {
        throw new \RuntimeException('increment not implemented');
    }

    public function decrement($amount): void
    {
        throw new \RuntimeException('decrement not implemented');
    }

}
