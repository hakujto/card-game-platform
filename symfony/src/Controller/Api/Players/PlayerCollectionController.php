<?php

namespace App\Controller\Api\Players;

use App\Entity\Players\PlayerCollection;
use App\Repository\Players\PlayerCollectionRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;

#[Route('/api/player_collections', name: 'playerCollection_')]
class PlayerCollectionController extends AbstractController
{
    public function __construct(
        private PlayerCollectionRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private CardRepository $cardRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['playerCollection:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $playerCollection = new PlayerCollection();
        if (isset($data['quantity'])) $playerCollection->setQuantity($data['quantity']);
        if (isset($data['foil'])) $playerCollection->setFoil($data['foil']);
        if (isset($data['condition'])) $playerCollection->setCondition($data['condition']);
        if (isset($data['acquiredAt'])) $playerCollection->setAcquiredAt(new \DateTime($data['acquiredAt']));
        if (isset($data['acquiredVia'])) $playerCollection->setAcquiredVia($data['acquiredVia']);
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $playerCollection->setPlayer($rel_player);
        if (!isset($data['card'])) return $this->json(['error' => 'card is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_card = $this->cardRepository->find($data['card']);
        if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $playerCollection->setCard($rel_card);

        $errors = $this->validator->validate($playerCollection);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($playerCollection, flush: true);
        return $this->json($playerCollection, Response::HTTP_CREATED, context: ['groups' => ['playerCollection:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(PlayerCollection $playerCollection): JsonResponse
    {
        return $this->json($playerCollection, context: ['groups' => ['playerCollection:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, PlayerCollection $playerCollection): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['quantity'])) $playerCollection->setQuantity($data['quantity']);
        if (isset($data['foil'])) $playerCollection->setFoil($data['foil']);
        if (isset($data['condition'])) $playerCollection->setCondition($data['condition']);
        if (isset($data['acquiredAt'])) $playerCollection->setAcquiredAt(new \DateTime($data['acquiredAt']));
        if (isset($data['acquiredVia'])) $playerCollection->setAcquiredVia($data['acquiredVia']);
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $playerCollection->setPlayer($rel_player);
        }
        if (isset($data['card'])) {
            $rel_card = $this->cardRepository->find($data['card']);
            if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $playerCollection->setCard($rel_card);
        }

        $errors = $this->validator->validate($playerCollection);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($playerCollection, flush: true);
        return $this->json($playerCollection, context: ['groups' => ['playerCollection:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(PlayerCollection $playerCollection): JsonResponse
    {
        $this->repository->remove($playerCollection, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/add', name: 'add', methods: ['POST'])]
    public function add(PlayerCollection $playerCollection, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $playerCollection->add($data['quantity'] ?? null);
        $this->repository->save($playerCollection, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/remove', name: 'remove', methods: ['POST'])]
    public function remove(PlayerCollection $playerCollection, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $playerCollection->remove($data['quantity'] ?? null);
        $this->repository->save($playerCollection, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/value', name: 'estimatedValue', methods: ['GET'])]
    public function estimatedValue(PlayerCollection $playerCollection): JsonResponse
    {
        $result = $playerCollection->estimatedValue();
        $this->repository->save($playerCollection, flush: true);
        return $this->json($result);
    }
}
