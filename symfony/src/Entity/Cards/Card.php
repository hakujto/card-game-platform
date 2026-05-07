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

    #[ORM\ManyToOne(targetEntity: CardRuling::class, inversedBy: 'card')]
    #[ORM\JoinColumn(nullable: true)]
    private ?CardRuling $rulings = null;

    #[ORM\ManyToOne(targetEntity: CardAbility::class, inversedBy: 'card')]
    #[ORM\JoinColumn(nullable: true)]
    private ?CardAbility $abilities = null;

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

    #[Groups(['card:read'])]
    public function getRulingsId(): ?int
    {
        return $this->rulings?->getId();
    }

    public function getRulings(): ?CardRuling
    {
        return $this->rulings;
    }

    public function setRulings(?CardRuling $rulings): static
    {
        $this->rulings = $rulings;
        return $this;
    }

    #[Groups(['card:read'])]
    public function getAbilitiesId(): ?int
    {
        return $this->abilities?->getId();
    }

    public function getAbilities(): ?CardAbility
    {
        return $this->abilities;
    }

    public function setAbilities(?CardAbility $abilities): static
    {
        $this->abilities = $abilities;
        return $this;
    }

}
