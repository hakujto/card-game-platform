<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Cards\DeckRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use App\Entity\Players\Player;

#[ORM\Entity(repositoryClass: DeckRepository::class)]
#[ORM\Table(name: 'deck')]
class Deck
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['deck:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 100)]
    #[Groups(['deck:read', 'deck:write'])]
    private string $name = '';

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['deck:read', 'deck:write'])]
    private ?string $description = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['deck:read', 'deck:write'])]
    private string $format = 'Standard';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['deck:read', 'deck:write'])]
    private bool $isPublic = false;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['deck:read', 'deck:write'])]
    private bool $isTournamentLegal = false;

    #[ORM\Column(type: 'string', length: 20, nullable: true)]
    #[Groups(['deck:read', 'deck:write'])]
    private ?string $archetype = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['deck:read', 'deck:write'])]
    private int $wins = 0;

    #[ORM\Column(type: 'integer')]
    #[Groups(['deck:read', 'deck:write'])]
    private int $losses = 0;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['deck:read', 'deck:write'])]
    private ?\DateTimeInterface $createdAt = null;

    #[ORM\Column(type: 'datetime', nullable: true)]
    #[Groups(['deck:read', 'deck:write'])]
    private ?\DateTimeInterface $updatedAt = null;

    #[ORM\ManyToOne(targetEntity: Player::class, inversedBy: 'decks')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Player $player = null;

    #[ORM\ManyToMany(targetEntity: Card::class)]
    #[ORM\JoinTable(name: 'deck_cards_m2m')]
    private Collection $cards;

    #[ORM\ManyToMany(targetEntity: Card::class)]
    #[ORM\JoinTable(name: 'deck_sideboard_cards_m2m')]
    private Collection $sideboardCards;

    #[ORM\ManyToMany(targetEntity: DeckTag::class)]
    #[ORM\JoinTable(name: 'deck_tags_m2m')]
    private Collection $tags;

    public function __construct()
    {
        $this->cards = new ArrayCollection();
        $this->sideboardCards = new ArrayCollection();
        $this->tags = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function setName(string $name): static
    {
        $this->name = $name;
        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): static
    {
        $this->description = $description;
        return $this;
    }

    public function getFormat(): string
    {
        return $this->format;
    }

    public function setFormat(string $format): static
    {
        $this->format = $format;
        return $this;
    }

    public function getIsPublic(): bool
    {
        return $this->isPublic;
    }

    public function setIsPublic(bool $isPublic): static
    {
        $this->isPublic = $isPublic;
        return $this;
    }

    public function getIsTournamentLegal(): bool
    {
        return $this->isTournamentLegal;
    }

    public function setIsTournamentLegal(bool $isTournamentLegal): static
    {
        $this->isTournamentLegal = $isTournamentLegal;
        return $this;
    }

    public function getArchetype(): ?string
    {
        return $this->archetype;
    }

    public function setArchetype(?string $archetype): static
    {
        $this->archetype = $archetype;
        return $this;
    }

    public function getWins(): int
    {
        return $this->wins;
    }

    public function setWins(int $wins): static
    {
        $this->wins = $wins;
        return $this;
    }

    public function getLosses(): int
    {
        return $this->losses;
    }

    public function setLosses(int $losses): static
    {
        $this->losses = $losses;
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

    #[Groups(['deck:read'])]
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

    public function getCards(): Collection
    {
        return $this->cards;
    }

    public function addCards(Card $item): static
    {
        if (!$this->cards->contains($item)) {
            $this->cards->add($item);
        }
        return $this;
    }

    public function removeCards(Card $item): static
    {
        $this->cards->removeElement($item);
        return $this;
    }

    public function getSideboardCards(): Collection
    {
        return $this->sideboardCards;
    }

    public function addSideboardCards(Card $item): static
    {
        if (!$this->sideboardCards->contains($item)) {
            $this->sideboardCards->add($item);
        }
        return $this;
    }

    public function removeSideboardCards(Card $item): static
    {
        $this->sideboardCards->removeElement($item);
        return $this;
    }

    public function getTags(): Collection
    {
        return $this->tags;
    }

    public function addTags(DeckTag $item): static
    {
        if (!$this->tags->contains($item)) {
            $this->tags->add($item);
        }
        return $this;
    }

    public function removeTags(DeckTag $item): static
    {
        $this->tags->removeElement($item);
        return $this;
    }

    // ── Business operations ──────────────────────────────────────────

    public function validateSize(): void
    {
        throw new \RuntimeException('validate_size not implemented');
    }

    public function clone(): void
    {
        throw new \RuntimeException('clone not implemented');
    }

    public function publish(): void
    {
        throw new \RuntimeException('publish not implemented');
    }

    public function unpublish(): void
    {
        throw new \RuntimeException('unpublish not implemented');
    }

    public function certifyTournamentLegal(): void
    {
        throw new \RuntimeException('certify_tournament_legal not implemented');
    }

}
