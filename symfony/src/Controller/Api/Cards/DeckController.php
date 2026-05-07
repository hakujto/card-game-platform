<?php

namespace App\Controller\Api\Cards;

use App\Entity\Cards\Deck;
use App\Repository\Cards\DeckRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/decks', name: 'deck_')]
class DeckController extends AbstractController
{
    public function __construct(
        private DeckRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['deck:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $deck = new Deck();
        if (isset($data['name'])) $deck->setName($data['name']);
        if (isset($data['description'])) $deck->setDescription($data['description']);
        if (isset($data['format'])) $deck->setFormat($data['format']);
        if (isset($data['isPublic'])) $deck->setIsPublic($data['isPublic']);
        if (isset($data['isTournamentLegal'])) $deck->setIsTournamentLegal($data['isTournamentLegal']);
        if (isset($data['archetype'])) $deck->setArchetype($data['archetype']);
        if (isset($data['wins'])) $deck->setWins($data['wins']);
        if (isset($data['losses'])) $deck->setLosses($data['losses']);
        if (isset($data['createdAt'])) $deck->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['updatedAt'])) $deck->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $deck->setPlayer($rel_player);

        $errors = $this->validator->validate($deck);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deck, flush: true);
        return $this->json($deck, Response::HTTP_CREATED, context: ['groups' => ['deck:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Deck $deck): JsonResponse
    {
        return $this->json($deck, context: ['groups' => ['deck:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Deck $deck): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['name'])) $deck->setName($data['name']);
        if (isset($data['description'])) $deck->setDescription($data['description']);
        if (isset($data['format'])) $deck->setFormat($data['format']);
        if (isset($data['isPublic'])) $deck->setIsPublic($data['isPublic']);
        if (isset($data['isTournamentLegal'])) $deck->setIsTournamentLegal($data['isTournamentLegal']);
        if (isset($data['archetype'])) $deck->setArchetype($data['archetype']);
        if (isset($data['wins'])) $deck->setWins($data['wins']);
        if (isset($data['losses'])) $deck->setLosses($data['losses']);
        if (isset($data['createdAt'])) $deck->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['updatedAt'])) $deck->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $deck->setPlayer($rel_player);
        }

        $errors = $this->validator->validate($deck);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($deck, flush: true);
        return $this->json($deck, context: ['groups' => ['deck:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Deck $deck): JsonResponse
    {
        $this->repository->remove($deck, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
