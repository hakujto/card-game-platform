<?php

namespace App\Entity\Players;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Players\CraftingRecipeRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use App\Entity\Cards\Card;

#[ORM\Entity(repositoryClass: CraftingRecipeRepository::class)]
#[ORM\Table(name: 'crafting_recipe')]
class CraftingRecipe
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['craftingRecipe:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['craftingRecipe:read', 'craftingRecipe:write'])]
    private int $dustCost = 0;

    #[ORM\Column(type: 'boolean')]
    #[Groups(['craftingRecipe:read', 'craftingRecipe:write'])]
    private bool $isAvailable = true;

    #[ORM\ManyToOne(targetEntity: Card::class, inversedBy: 'crafting_recipes')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Card $resultCard = null;

    #[ORM\ManyToMany(targetEntity: Card::class)]
    #[ORM\JoinTable(name: 'crafting_recipe_required_cards_m2m')]
    private Collection $requiredCards;

    public function __construct()
    {
        $this->requiredCards = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getDustCost(): int
    {
        return $this->dustCost;
    }

    public function setDustCost(int $dustCost): static
    {
        $this->dustCost = $dustCost;
        return $this;
    }

    public function getIsAvailable(): bool
    {
        return $this->isAvailable;
    }

    public function setIsAvailable(bool $isAvailable): static
    {
        $this->isAvailable = $isAvailable;
        return $this;
    }

    #[Groups(['craftingRecipe:read'])]
    public function getResultCardId(): ?int
    {
        return $this->resultCard?->getId();
    }

    public function getResultCard(): ?Card
    {
        return $this->resultCard;
    }

    public function setResultCard(?Card $resultCard): static
    {
        $this->resultCard = $resultCard;
        return $this;
    }

    public function getRequiredCards(): Collection
    {
        return $this->requiredCards;
    }

    public function addRequiredCards(Card $item): static
    {
        if (!$this->requiredCards->contains($item)) {
            $this->requiredCards->add($item);
        }
        return $this;
    }

    public function removeRequiredCards(Card $item): static
    {
        $this->requiredCards->removeElement($item);
        return $this;
    }

    // ── Business operations ──────────────────────────────────────────

    public function disable(): void
    {
        throw new \RuntimeException('disable not implemented');
    }

    public function enable(): void
    {
        throw new \RuntimeException('enable not implemented');
    }

}
