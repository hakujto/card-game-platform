<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Cards\DeckCardRepository;

#[ORM\Entity(repositoryClass: DeckCardRepository::class)]
#[ORM\Table(name: 'deck_card')]
class DeckCard
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['deckCard:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['deckCard:read', 'deckCard:write'])]
    private int $quantity = 1;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['deckCard:read', 'deckCard:write'])]
    private bool $isCommander = false;

    #[ORM\ManyToOne(targetEntity: Deck::class, inversedBy: 'deck_cards')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Deck $deck = null;

    #[ORM\ManyToOne(targetEntity: Card::class, inversedBy: 'deck_cards')]
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

    public function getIsCommander(): bool
    {
        return $this->isCommander;
    }

    public function setIsCommander(bool $isCommander): static
    {
        $this->isCommander = $isCommander;
        return $this;
    }

    #[Groups(['deckCard:read'])]
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

    #[Groups(['deckCard:read'])]
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

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "A deck can contain between 1 and 4 copies of a card")]
    public function isQuantityRangeValid(): bool
    {
        return ($this->getQuantity() === null || ($this->getQuantity() >= 1 && $this->getQuantity() <= 4));
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
