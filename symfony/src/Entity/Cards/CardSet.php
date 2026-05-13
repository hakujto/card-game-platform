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

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['cardSet:read', 'cardSet:write'])]
    private string $setType = 'Expansion';

    #[ORM\Column(type: 'integer')]
    #[Groups(['cardSet:read', 'cardSet:write'])]
    private int $totalCards = 0;

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

    // ── Business operations ──────────────────────────────────────────

    public function isLegalInStandard(): void
    {
        throw new \RuntimeException('is_legal_in_standard not implemented');
    }

}
