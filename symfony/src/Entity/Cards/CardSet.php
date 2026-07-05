<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Cards\CardSetRepository;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use App\Entity\Marketplace\Product;
use App\Entity\Content\DraftSession;

#[ORM\Entity(repositoryClass: CardSetRepository::class)]
#[ORM\Table(name: 'card_set')]
#[UniqueEntity(fields: ['code'], message: 'code must be unique')]
class CardSet
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['cardSet:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 200)]
    #[Groups(['cardSet:read', 'cardSet:write'])]
    private string $name = '';

    #[ORM\Column(type: 'string', length: 10, unique: true)]
    #[Groups(['cardSet:read', 'cardSet:write'])]
    #[Assert\Regex(pattern: '/[A-Z]{2,6}/')]
    private string $code = '';

    #[ORM\Column(type: 'date', nullable: true)]
    #[Groups(['cardSet:read', 'cardSet:write'])]
    private ?\DateTimeInterface $releaseDate = null;

    #[ORM\Column(type: 'date', nullable: true)]
    #[Groups(['cardSet:read', 'cardSet:write'])]
    private ?\DateTimeInterface $rotationDate = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['cardSet:read', 'cardSet:write'])]
    private string $setType = 'Expansion';

    #[ORM\Column(type: 'integer')]
    #[Groups(['cardSet:read', 'cardSet:write'])]
    private int $totalCards = 0;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['cardSet:read', 'cardSet:write'])]
    private bool $isRotated = false;

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['cardSet:read', 'cardSet:write'])]
    private ?string $description = null;

    #[ORM\Column(type: 'string', length: 200, nullable: true)]
    #[Groups(['cardSet:read', 'cardSet:write'])]
    private ?string $logoUrl = null;

    #[ORM\OneToMany(mappedBy: 'set', targetEntity: Card::class)]
    private Collection $cards;

    #[ORM\OneToMany(mappedBy: 'cardSet', targetEntity: Product::class)]
    private Collection $shopProducts;

    #[ORM\OneToMany(mappedBy: 'cardSet', targetEntity: DraftSession::class)]
    private Collection $draftSessions;

    public function __construct()
    {
        $this->cards = new ArrayCollection();
        $this->shopProducts = new ArrayCollection();
        $this->draftSessions = new ArrayCollection();
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

    public function getCode(): string
    {
        return $this->code;
    }

    public function setCode(string $code): static
    {
        $this->code = $code;
        return $this;
    }

    public function getReleaseDate(): ?\DateTimeInterface
    {
        return $this->releaseDate;
    }

    public function setReleaseDate(?\DateTimeInterface $releaseDate): static
    {
        $this->releaseDate = $releaseDate;
        return $this;
    }

    public function getRotationDate(): ?\DateTimeInterface
    {
        return $this->rotationDate;
    }

    public function setRotationDate(?\DateTimeInterface $rotationDate): static
    {
        $this->rotationDate = $rotationDate;
        return $this;
    }

    public function getSetType(): string
    {
        return $this->setType;
    }

    public function setSetType(string $setType): static
    {
        $this->setType = $setType;
        return $this;
    }

    public function getTotalCards(): int
    {
        return $this->totalCards;
    }

    public function setTotalCards(int $totalCards): static
    {
        $this->totalCards = $totalCards;
        return $this;
    }

    public function getIsRotated(): bool
    {
        return $this->isRotated;
    }

    public function setIsRotated(bool $isRotated): static
    {
        $this->isRotated = $isRotated;
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

    public function getLogoUrl(): ?string
    {
        return $this->logoUrl;
    }

    public function setLogoUrl(?string $logoUrl): static
    {
        $this->logoUrl = $logoUrl;
        return $this;
    }

    public function getCards(): Collection
    {
        return $this->cards;
    }

    public function getShopProducts(): Collection
    {
        return $this->shopProducts;
    }

    public function getDraftSessions(): Collection
    {
        return $this->draftSessions;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Card set must have at least one card")]
    public function isTotalCardsPositiveValid(): bool
    {
        return ($this->getTotalCards() === null || $this->getTotalCards() > 0);
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getRotationDate() !== null && !(($this->getRotationDate() === null || ($this->getReleaseDate() !== null && $this->getRotationDate() > $this->getReleaseDate())))) {
            throw new \DomainException('Rotation date must be after release date');
        }
        if ($this->getIsRotated() === true && $this->getRotationDate() === null) {
            throw new \DomainException('Rotated set must have a rotation date');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function isLegalInStandard(): mixed
    {
        // TODO: implement is_legal_in_standard
        return null;
    }

    public function isLegalInFormat($format): mixed
    {
        // TODO: implement is_legal_in_format
        return null;
    }

    public function cardCountByRarity($rarity): mixed
    {
        // TODO: implement card_count_by_rarity
        return null;
    }

    public function rotateOut(): void
    {
        // TODO: implement rotate_out
    }

}
