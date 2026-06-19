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

    #[ORM\ManyToOne(targetEntity: Card::class, inversedBy: 'craftingRecipes')]
    #[ORM\JoinColumn(nullable: false, onDelete: 'RESTRICT')]
    private ?Card $resultCard = null;

    #[ORM\OneToMany(mappedBy: 'recipe', targetEntity: CraftingIngredient::class)]
    private Collection $ingredients;

    public function __construct()
    {
        $this->ingredients = new ArrayCollection();
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

    public function getIngredients(): Collection
    {
        return $this->ingredients;
    }

    // ── Validation rules ─────────────────────────────────────────────
    #[\Symfony\Component\Validator\Constraints\IsTrue(message: "Crafting recipe must have a dust cost greater than zero")]
    public function isDustCostPositiveValid(): bool
    {
        return ($this->getDustCost() === null || $this->getDustCost() > 0);
    }

    // ── Business operations ──────────────────────────────────────────

    public function canCraft($playerId): mixed
    {
        // TODO: implement can_craft
        return null;
    }

    public function executeCraft($playerId): void
    {
        // TODO: implement execute_craft
    }

    public function disable(): void
    {
        // TODO: implement disable
    }

    public function enable(): void
    {
        // TODO: implement enable
    }

}
