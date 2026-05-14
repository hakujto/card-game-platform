<?php

namespace App\Controller\Api\Cards;

use App\Entity\Cards\CardAbility;
use App\Repository\Cards\CardAbilityRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;

#[Route('/api/card_abilities', name: 'cardAbility_')]
class CardAbilityController extends AbstractController
{
    public function __construct(
        private CardAbilityRepository $repository,
        private ValidatorInterface $validator,
        private CardRepository $cardRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['cardAbility:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $cardAbility = new CardAbility();
        if (isset($data['abilityType'])) $cardAbility->setAbilityType($data['abilityType']);
        if (isset($data['keyword'])) $cardAbility->setKeyword($data['keyword']);
        if (isset($data['abilityText'])) $cardAbility->setAbilityText($data['abilityText']);
        if (isset($data['timing'])) $cardAbility->setTiming($data['timing']);
        if (!isset($data['card'])) return $this->json(['error' => 'card is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_card = $this->cardRepository->find($data['card']);
        if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $cardAbility->setCard($rel_card);

        $errors = $this->validator->validate($cardAbility);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $cardAbility->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($cardAbility, flush: true);
        return $this->json($cardAbility, Response::HTTP_CREATED, context: ['groups' => ['cardAbility:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(CardAbility $cardAbility): JsonResponse
    {
        return $this->json($cardAbility, context: ['groups' => ['cardAbility:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, CardAbility $cardAbility): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['abilityType'])) $cardAbility->setAbilityType($data['abilityType']);
        if (isset($data['keyword'])) $cardAbility->setKeyword($data['keyword']);
        if (isset($data['abilityText'])) $cardAbility->setAbilityText($data['abilityText']);
        if (isset($data['timing'])) $cardAbility->setTiming($data['timing']);
        if (isset($data['card'])) {
            $rel_card = $this->cardRepository->find($data['card']);
            if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $cardAbility->setCard($rel_card);
        }

        $errors = $this->validator->validate($cardAbility);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $cardAbility->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($cardAbility, flush: true);
        return $this->json($cardAbility, context: ['groups' => ['cardAbility:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(CardAbility $cardAbility): JsonResponse
    {
        $this->repository->remove($cardAbility, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

}
