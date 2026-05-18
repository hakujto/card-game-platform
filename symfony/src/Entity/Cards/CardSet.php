<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Cards\CardSetRepository;

#[ORM\Entity(repositoryClass: CardSetRepository::class)]
#[ORM\Table(name: 'card_set')]
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

    #[ORM\Column(type: 'string', length: 10)]
    #[Groups(['cardSet:read', 'cardSet:write'])]
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

    public function isLegalInStandard(): void
    {
        throw new \RuntimeException('is_legal_in_standard not implemented');
    }

    public function isLegalInFormat($format): void
    {
        throw new \RuntimeException('is_legal_in_format not implemented');
    }

    public function cardCountByRarity($rarity): void
    {
        throw new \RuntimeException('card_count_by_rarity not implemented');
    }

    public function rotateOut(): void
    {
        throw new \RuntimeException('rotate_out not implemented');
    }

}
