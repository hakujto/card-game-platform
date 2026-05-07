<?php

namespace App\Entity\Players;

use Doctrine\ORM\Mapping as ORM;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Repository\Players\CraftingIngredientRepository;
use App\Entity\Cards\Card;

#[ORM\Entity(repositoryClass: CraftingIngredientRepository::class)]
#[ORM\Table(name: 'crafting_ingredient')]
class CraftingIngredient
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    #[Groups(['craftingIngredient:read'])]
    private ?int $id = null;

    #[ORM\Column(type: 'integer')]
    #[Groups(['craftingIngredient:read', 'craftingIngredient:write'])]
    private int $quantity = 1;

    #[ORM\ManyToOne(targetEntity: CraftingRecipe::class, inversedBy: 'ingredients')]
    #[ORM\JoinColumn(nullable: false)]
    private ?CraftingRecipe $recipe = null;

    #[ORM\ManyToOne(targetEntity: Card::class, inversedBy: 'used_in_recipes')]
    #[ORM\JoinColumn(nullable: false)]
    private ?Card $card = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getQuantity(): int
    {
        return $this->quantity;
    }

    public function setQuantity(int $quantity): static
    {
        $this->quantity = $quantity;
        return $this;
    }

    #[Groups(['craftingIngredient:read'])]
    public function getRecipeId(): ?int
    {
        return $this->recipe?->getId();
    }

    public function getRecipe(): ?CraftingRecipe
    {
        return $this->recipe;
    }

    public function setRecipe(?CraftingRecipe $recipe): static
    {
        $this->recipe = $recipe;
        return $this;
    }

    #[Groups(['craftingIngredient:read'])]
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

}
