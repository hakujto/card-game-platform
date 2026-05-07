<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Cards\DeckTagAssignmentRepository;

#[ORM\Entity(repositoryClass: DeckTagAssignmentRepository::class)]
#[ORM\Table(name: 'deck_tag_assignment')]
class DeckTagAssignment
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['deckTagAssignment:read'])]
    private ?int $id = null;

    #[ORM\ManyToOne(targetEntity: Deck::class, inversedBy: 'tag_assignments')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Deck $deck = null;

    #[ORM\ManyToOne(targetEntity: DeckTag::class, inversedBy: 'deck_assignments')]
    #[ORM\JoinColumn(nullable: false)]
    private ?DeckTag $tag = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    #[Groups(['deckTagAssignment:read'])]
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

    #[Groups(['deckTagAssignment:read'])]
    public function getTagId(): ?int
    {
        return $this->tag?->getId();
    }

    public function getTag(): ?DeckTag
    {
        return $this->tag;
    }

    public function setTag(?DeckTag $tag): static
    {
        $this->tag = $tag;
        return $this;
    }

}
