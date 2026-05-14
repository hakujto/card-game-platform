<?php

namespace App\Controller\Api\Content;

use App\Entity\Content\DraftParticipant;
use App\Repository\Content\DraftParticipantRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Content\DraftSession;
use App\Repository\Content\DraftSessionRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/draft_participants', name: 'draftParticipant_')]
class DraftParticipantController extends AbstractController
{
    public function __construct(
        private DraftParticipantRepository $repository,
        private ValidatorInterface $validator,
        private DraftSessionRepository $draftSessionRepository,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['draftParticipant:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $draftParticipant = new DraftParticipant();
        if (isset($data['seatNumber'])) $draftParticipant->setSeatNumber($data['seatNumber']);
        if (isset($data['joinedAt'])) $draftParticipant->setJoinedAt(new \DateTime($data['joinedAt']));
        if (array_key_exists('session', $data)) {
            $draftParticipant->setSession($data['session'] !== null ? $this->draftSessionRepository->find($data['session']) : null);
        }
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $draftParticipant->setPlayer($rel_player);

        $errors = $this->validator->validate($draftParticipant);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($draftParticipant, flush: true);
        return $this->json($draftParticipant, Response::HTTP_CREATED, context: ['groups' => ['draftParticipant:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(DraftParticipant $draftParticipant): JsonResponse
    {
        return $this->json($draftParticipant, context: ['groups' => ['draftParticipant:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, DraftParticipant $draftParticipant): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['seatNumber'])) $draftParticipant->setSeatNumber($data['seatNumber']);
        if (isset($data['joinedAt'])) $draftParticipant->setJoinedAt(new \DateTime($data['joinedAt']));
        if (array_key_exists('session', $data)) {
            $draftParticipant->setSession($data['session'] !== null ? $this->draftSessionRepository->find($data['session']) : null);
        }
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $draftParticipant->setPlayer($rel_player);
        }

        $errors = $this->validator->validate($draftParticipant);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($draftParticipant, flush: true);
        return $this->json($draftParticipant, context: ['groups' => ['draftParticipant:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(DraftParticipant $draftParticipant): JsonResponse
    {
        $this->repository->remove($draftParticipant, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/pick', name: 'pickCard', methods: ['POST'])]
    public function pickCard(DraftParticipant $draftParticipant, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $draftParticipant->pickCard($data['cardId'] ?? null, $data['packNumber'] ?? null);
        $this->repository->save($draftParticipant, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
