<?php

namespace App\Controller\Api\Players;

use App\Entity\Players\CraftingRecipe;
use App\Repository\Players\CraftingRecipeRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;

#[Route('/api/crafting_recipes', name: 'craftingRecipe_')]
class CraftingRecipeController extends AbstractController
{
    public function __construct(
        private CraftingRecipeRepository $repository,
        private ValidatorInterface $validator,
        private CardRepository $cardRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['craftingRecipe:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $craftingRecipe = new CraftingRecipe();
        if (isset($data['dustCost'])) $craftingRecipe->setDustCost($data['dustCost']);
        if (isset($data['isAvailable'])) $craftingRecipe->setIsAvailable($data['isAvailable']);
        if (!isset($data['resultCard'])) return $this->json(['error' => 'resultCard is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_resultCard = $this->cardRepository->find($data['resultCard']);
        if (!$rel_resultCard) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $craftingRecipe->setResultCard($rel_resultCard);

        $errors = $this->validator->validate($craftingRecipe);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($craftingRecipe, flush: true);
        return $this->json($craftingRecipe, Response::HTTP_CREATED, context: ['groups' => ['craftingRecipe:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(CraftingRecipe $craftingRecipe): JsonResponse
    {
        return $this->json($craftingRecipe, context: ['groups' => ['craftingRecipe:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, CraftingRecipe $craftingRecipe): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['dustCost'])) $craftingRecipe->setDustCost($data['dustCost']);
        if (isset($data['isAvailable'])) $craftingRecipe->setIsAvailable($data['isAvailable']);
        if (isset($data['resultCard'])) {
            $rel_resultCard = $this->cardRepository->find($data['resultCard']);
            if (!$rel_resultCard) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $craftingRecipe->setResultCard($rel_resultCard);
        }

        $errors = $this->validator->validate($craftingRecipe);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($craftingRecipe, flush: true);
        return $this->json($craftingRecipe, context: ['groups' => ['craftingRecipe:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(CraftingRecipe $craftingRecipe): JsonResponse
    {
        $this->repository->remove($craftingRecipe, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/can-craft', name: 'canCraft', methods: ['GET'])]
    public function canCraft(CraftingRecipe $craftingRecipe): JsonResponse
    {
        $result = $craftingRecipe->canCraft($playerId);
        $this->repository->save($craftingRecipe, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/craft', name: 'executeCraft', methods: ['POST'])]
    public function executeCraft(CraftingRecipe $craftingRecipe, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $craftingRecipe->executeCraft($data['playerId'] ?? null);
        $this->repository->save($craftingRecipe, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/disable', name: 'disable', methods: ['POST'])]
    public function disable(CraftingRecipe $craftingRecipe): JsonResponse
    {
        $craftingRecipe->disable();
        $this->repository->save($craftingRecipe, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/enable', name: 'enable', methods: ['POST'])]
    public function enable(CraftingRecipe $craftingRecipe): JsonResponse
    {
        $craftingRecipe->enable();
        $this->repository->save($craftingRecipe, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
