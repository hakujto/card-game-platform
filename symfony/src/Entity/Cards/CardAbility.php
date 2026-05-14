<?php

namespace App\Entity\Cards;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Cards\CardAbilityRepository;

#[ORM\Entity(repositoryClass: CardAbilityRepository::class)]
#[ORM\Table(name: 'card_ability')]
class CardAbility
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['cardAbility:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'string', length: 20)]
    #[Groups(['cardAbility:read', 'cardAbility:write'])]
    private string $abilityType = 'Keyword';

    #[ORM\Column(type: 'string', length: 100, nullable: true)]
    #[Groups(['cardAbility:read', 'cardAbility:write'])]
    private ?string $keyword = null;

    #[ORM\Column(type: 'text')]
    #[Groups(['cardAbility:read', 'cardAbility:write'])]
    private string $abilityText = '';

    #[ORM\Column(type: 'string', length: 20, nullable: true)]
    #[Groups(['cardAbility:read', 'cardAbility:write'])]
    private ?string $timing = null;

    #[ORM\ManyToOne(targetEntity: Card::class, inversedBy: 'abilities')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Card $card = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getAbilityType(): string
    {
        return $this->abilityType;
    }

    public function setAbilityType(string $abilityType): static
    {
        $this->abilityType = $abilityType;
        return $this;
    }

    public function getKeyword(): ?string
    {
        return $this->keyword;
    }

    public function setKeyword(?string $keyword): static
    {
        $this->keyword = $keyword;
        return $this;
    }

    public function getAbilityText(): string
    {
        return $this->abilityText;
    }

    public function setAbilityText(string $abilityText): static
    {
        $this->abilityText = $abilityText;
        return $this;
    }

    public function getTiming(): ?string
    {
        return $this->timing;
    }

    public function setTiming(?string $timing): static
    {
        $this->timing = $timing;
        return $this;
    }

    #[Groups(['cardAbility:read'])]
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

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->getAbilityType() === 'KEYWORD' && $this->getKeyword() === null) {
            throw new \DomainException('Keyword ability must have a keyword name');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function isUsableAt($timing): void
    {
        throw new \RuntimeException('is_usable_at not implemented');
    }

    public function describe(): void
    {
        throw new \RuntimeException('describe not implemented');
    }

}
