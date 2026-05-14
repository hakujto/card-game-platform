<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Cards\CardRepository;

#[ORM\Entity(repositoryClass: CardRepository::class)]
#[ORM\Table(name: 'card')]
class Card
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['card:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 200)]
    #[Groups(['card:read', 'card:write'])]
    private string $name = '';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['card:read', 'card:write'])]
    private string $cardType = 'Creature';

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['card:read', 'card:write'])]
    private string $rarity = 'Common';

    #[ORM\Column(type: 'integer')]
    #[Groups(['card:read', 'card:write'])]
    private int $manaCost = 0;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['card:read', 'card:write'])]
    private string $manaColors = '';

    #[ORM\Column(type: 'integer', nullable: true)]
    #[Groups(['card:read', 'card:write'])]
    private ?int $attack = null;

    #[ORM\Column(type: 'integer', nullable: true)]
    #[Groups(['card:read', 'card:write'])]
    private ?int $defense = null;

    #[ORM\Column(type: 'integer', nullable: true)]
    #[Groups(['card:read', 'card:write'])]
    private ?int $loyalty = null;

    #[ORM\Column(type: 'text')]
    #[Groups(['card:read', 'card:write'])]
    private string $description = '';

    #[ORM\Column(type: 'text', nullable: true)]
    #[Groups(['card:read', 'card:write'])]
    private ?string $flavorText = null;

    #[ORM\Column(type: 'string', length: 200, nullable: true)]
    #[Groups(['card:read', 'card:write'])]
    private ?string $imageUrl = null;

    #[ORM\Column(type: 'string', length: 100, nullable: true)]
    #[Groups(['card:read', 'card:write'])]
    private ?string $artistName = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['card:read', 'card:write'])]
    private string $legalFormats = '';

    #[ORM\Column(type: 'boolean')]
    #[Groups(['card:read', 'card:write'])]
    private bool $isBanned = false;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['card:read', 'card:write'])]
    private bool $isRestricted = false;

    #[ORM\Column(type: 'integer')]
    #[Groups(['card:read', 'card:write'])]
    private int $powerLevel = 1;

    #[ORM\ManyToOne(targetEntity: CardSet::class, inversedBy: 'cards')]
    #[ORM\JoinColumn(nullable: false)]
    private ?CardSet $set = null;

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

    public function getCardType(): string
    {
        return $this->cardType;
    }

    public function setCardType(string $cardType): static
    {
        $this->cardType = $cardType;
        return $this;
    }

    public function getRarity(): string
    {
        return $this->rarity;
    }

    public function setRarity(string $rarity): static
    {
        $this->rarity = $rarity;
        return $this;
    }

    public function getManaCost(): int
    {
        return $this->manaCost;
    }

    public function setManaCost(int $manaCost): static
    {
        $this->manaCost = $manaCost;
        return $this;
    }

    public function getManaColors(): string
    {
        return $this->manaColors;
    }

    public function setManaColors(string $manaColors): static
    {
        $this->manaColors = $manaColors;
        return $this;
    }

    public function getAttack(): ?int
    {
        return $this->attack;
    }

    public function setAttack(?int $attack): static
    {
        $this->attack = $attack;
        return $this;
    }

    public function getDefense(): ?int
    {
        return $this->defense;
    }

    public function setDefense(?int $defense): static
    {
        $this->defense = $defense;
        return $this;
    }

    public function getLoyalty(): ?int
    {
        return $this->loyalty;
    }

    public function setLoyalty(?int $loyalty): static
    {
        $this->loyalty = $loyalty;
        return $this;
    }

    public function getDescription(): string
    {
        return $this->description;
    }

    public function setDescription(string $description): static
    {
        $this->description = $description;
        return $this;
    }

    public function getFlavorText(): ?string
    {
        return $this->flavorText;
    }

    public function setFlavorText(?string $flavorText): static
    {
        $this->flavorText = $flavorText;
        return $this;
    }

    public function getImageUrl(): ?string
    {
        return $this->imageUrl;
    }

    public function setImageUrl(?string $imageUrl): static
    {
        $this->imageUrl = $imageUrl;
        return $this;
    }

    public function getArtistName(): ?string
    {
        return $this->artistName;
    }

    public function setArtistName(?string $artistName): static
    {
        $this->artistName = $artistName;
        return $this;
    }

    public function getLegalFormats(): string
    {
        return $this->legalFormats;
    }

    public function setLegalFormats(string $legalFormats): static
    {
        $this->legalFormats = $legalFormats;
        return $this;
    }

    public function getIsBanned(): bool
    {
        return $this->isBanned;
    }

    public function setIsBanned(bool $isBanned): static
    {
        $this->isBanned = $isBanned;
        return $this;
    }

    public function getIsRestricted(): bool
    {
        return $this->isRestricted;
    }

    public function setIsRestricted(bool $isRestricted): static
    {
        $this->isRestricted = $isRestricted;
        return $this;
    }

    public function getPowerLevel(): int
    {
        return $this->powerLevel;
    }

    public function setPowerLevel(int $powerLevel): static
    {
        $this->powerLevel = $powerLevel;
        return $this;
    }

    #[Groups(['card:read'])]
    public function getSetId(): ?int
    {
        return $this->set?->getId();
    }

    public function getSet(): ?CardSet
    {
        return $this->set;
    }

    public function setSet(?CardSet $set): static
    {
        $this->set = $set;
        return $this;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "mana_cost must be between 0 and 20")]
    public function isManaCostRangeValid(): bool
    {
        return ($this->getManaCost() === null || ($this->getManaCost() >= 0 && $this->getManaCost() <= 20));
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "power_level must be between 1 and 10")]
    public function isPowerLevelRangeValid(): bool
    {
        return ($this->getPowerLevel() === null || ($this->getPowerLevel() >= 1 && $this->getPowerLevel() <= 10));
    }

    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Card cannot be both banned and restricted at the same time")]
    public function isNotBannedAndRestrictedValid(): bool
    {
        return !(($this->getIsBanned() === true && $this->getIsRestricted() === true));
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getCardType() === 'CREATURE' && !($this->getAttack() !== null && $this->getDefense() !== null)) {
            throw new \DomainException('Creature card must have attack and defense');
        }
        if ($this->getCardType() === 'PLANESWALKER' && $this->getLoyalty() === null) {
            throw new \DomainException('Planeswalker card must have loyalty');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function ban(): void
    {
        throw new \RuntimeException('ban not implemented');
    }

    public function unban(): void
    {
        throw new \RuntimeException('unban not implemented');
    }

    public function restrict(): void
    {
        throw new \RuntimeException('restrict not implemented');
    }

    public function unrestrict(): void
    {
        throw new \RuntimeException('unrestrict not implemented');
    }

    public function calculateValue(): void
    {
        throw new \RuntimeException('calculate_value not implemented');
    }

}
