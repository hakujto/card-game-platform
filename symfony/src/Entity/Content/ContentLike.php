<?php

namespace App\Entity\Content;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Content\ContentLikeRepository;
use App\Entity\Players\Player;
use App\Entity\Cards\Deck;

#[ORM\Entity(repositoryClass: ContentLikeRepository::class)]
#[ORM\Table(name: 'content_like')]
class ContentLike
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['contentLike:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['contentLike:read', 'contentLike:write'])]
    private string $targetType = '';

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['contentLike:read', 'contentLike:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'likes')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    #[ORM\ManyToOne(targetEntity: Article::class, inversedBy: 'likes')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Article $article = null;

    #[ORM\ManyToOne(targetEntity: Deck::class, inversedBy: 'likes')]
    #[ORM\JoinColumn(nullable: true)]
    private ?Deck $deck = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getTargetType(): string
    {
        return $this->targetType;
    }

    public function setTargetType(string $targetType): static
    {
        $this->targetType = $targetType;
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

    #[Groups(['contentLike:read'])]
    public function getPlayerId(): ?int
    {
        return $this->player?->getId();
    }

    public function getPlayer(): ?Player
    {
        return $this->player;
    }

    public function setPlayer(?Player $player): static
    {
        $this->player = $player;
        return $this;
    }

    #[Groups(['contentLike:read'])]
    public function getArticleId(): ?int
    {
        return $this->article?->getId();
    }

    public function getArticle(): ?Article
    {
        return $this->article;
    }

    public function setArticle(?Article $article): static
    {
        $this->article = $article;
        return $this;
    }

    #[Groups(['contentLike:read'])]
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

}
