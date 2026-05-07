<?php

namespace App\Controller\Api\Players;

use App\Entity\Players\CraftingIngredient;
use App\Repository\Players\CraftingIngredientRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\CraftingRecipe;
use App\Repository\Players\CraftingRecipeRepository;
use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;

#[Route('/api/crafting_ingredients', name: 'craftingIngredient_')]
class CraftingIngredientController extends AbstractController
{
    public function __construct(
        private CraftingIngredientRepository $repository,
        private ValidatorInterface $validator,
        private CraftingRecipeRepository $craftingRecipeRepository,
        private CardRepository $cardRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['craftingIngredient:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $craftingIngredient = new CraftingIngredient();
        if (isset($data['quantity'])) $craftingIngredient->setQuantity($data['quantity']);
        if (!isset($data['recipe'])) return $this->json(['error' => 'recipe is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_recipe = $this->craftingRecipeRepository->find($data['recipe']);
        if (!$rel_recipe) return $this->json(['error' => 'CraftingRecipe not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $craftingIngredient->setRecipe($rel_recipe);
        if (!isset($data['card'])) return $this->json(['error' => 'card is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_card = $this->cardRepository->find($data['card']);
        if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $craftingIngredient->setCard($rel_card);

        $errors = $this->validator->validate($craftingIngredient);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($craftingIngredient, flush: true);
        return $this->json($craftingIngredient, Response::HTTP_CREATED, context: ['groups' => ['craftingIngredient:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(CraftingIngredient $craftingIngredient): JsonResponse
    {
        return $this->json($craftingIngredient, context: ['groups' => ['craftingIngredient:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, CraftingIngredient $craftingIngredient): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['quantity'])) $craftingIngredient->setQuantity($data['quantity']);
        if (isset($data['recipe'])) {
            $rel_recipe = $this->craftingRecipeRepository->find($data['recipe']);
            if (!$rel_recipe) return $this->json(['error' => 'CraftingRecipe not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $craftingIngredient->setRecipe($rel_recipe);
        }
        if (isset($data['card'])) {
            $rel_card = $this->cardRepository->find($data['card']);
            if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $craftingIngredient->setCard($rel_card);
        }

        $errors = $this->validator->validate($craftingIngredient);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($craftingIngredient, flush: true);
        return $this->json($craftingIngredient, context: ['groups' => ['craftingIngredient:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(CraftingIngredient $craftingIngredient): JsonResponse
    {
        $this->repository->remove($craftingIngredient, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
