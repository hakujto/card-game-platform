<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Content\DeckReviewRepository;
use App\Entity\Cards\Deck;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: DeckReviewRepository::class)]
#[ORM\Table(name: 'deck_review')]
class DeckReview
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['deckReview:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['deckReview:read', 'deckReview:write'])]
    private int $rating = 0;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['deckReview:read', 'deckReview:write'])]
    private ?string $body = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['deckReview:read', 'deckReview:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['deckReview:read', 'deckReview:write'])]
    private ?\DateTimeInterface $updatedAt = null;

    #[ORM\ManyToOne(targetEntity: Deck::class, inversedBy: 'reviews')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Deck $deck = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'deck_reviews')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $author = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getRating(): int
    {
        return $this->rating;
    }

    public function setRating(int $rating): static
    {
        $this->rating = $rating;
        return $this;
    }

    public function getBody(): ?string
    {
        return $this->body;
    }

    public function setBody(?string $body): static
    {
        $this->body = $body;
        return $this;
    }

    public function getCreatedAt(): ?\DateTimeInterface
    {
        return $this->createdAt;
    }

    public function setCreatedAt(?\DateTimeInterface $createdAt): static
    {
        $this->createdAt = $createdAt;
        return $this;
    }

    public function getUpdatedAt(): ?\DateTimeInterface
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?\DateTimeInterface $updatedAt): static
    {
        $this->updatedAt = $updatedAt;
        return $this;
    }

    #[Groups(['deckReview:read'])]
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

    #[Groups(['deckReview:read'])]
    public function getAuthorId(): ?int
    {
        return $this->author?->getId();
    }

    public function getAuthor(): ?Player
    {
        return $this->author;
    }

    public function setAuthor(?Player $author): static
    {
        $this->author = $author;
        return $this;
    }

}
