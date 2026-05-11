<?php

namespace App\Controller\Api\Leaderboard;

use App\Entity\Leaderboard\LeaderboardSnapshot;
use App\Repository\Leaderboard\LeaderboardSnapshotRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Leaderboard\LeaderboardEntry;
use App\Repository\Leaderboard\LeaderboardEntryRepository;

#[Route('/api/leaderboard_snapshots', name: 'leaderboardSnapshot_')]
class LeaderboardSnapshotController extends AbstractController
{
    public function __construct(
        private LeaderboardSnapshotRepository $repository,
        private ValidatorInterface $validator,
        private LeaderboardEntryRepository $leaderboardEntryRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['leaderboardSnapshot:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $leaderboardSnapshot = new LeaderboardSnapshot();
        if (isset($data['snapshotDate'])) $leaderboardSnapshot->setSnapshotDate(new \DateTime($data['snapshotDate']));
        if (isset($data['position'])) $leaderboardSnapshot->setPosition($data['position']);
        if (isset($data['rating'])) $leaderboardSnapshot->setRating($data['rating']);
        if (isset($data['seasonPoints'])) $leaderboardSnapshot->setSeasonPoints($data['seasonPoints']);
        if (!isset($data['entry'])) return $this->json(['error' => 'entry is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_entry = $this->leaderboardEntryRepository->find($data['entry']);
        if (!$rel_entry) return $this->json(['error' => 'LeaderboardEntry not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $leaderboardSnapshot->setEntry($rel_entry);

        $errors = $this->validator->validate($leaderboardSnapshot);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($leaderboardSnapshot, flush: true);
        return $this->json($leaderboardSnapshot, Response::HTTP_CREATED, context: ['groups' => ['leaderboardSnapshot:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(LeaderboardSnapshot $leaderboardSnapshot): JsonResponse
    {
        return $this->json($leaderboardSnapshot, context: ['groups' => ['leaderboardSnapshot:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, LeaderboardSnapshot $leaderboardSnapshot): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['snapshotDate'])) $leaderboardSnapshot->setSnapshotDate(new \DateTime($data['snapshotDate']));
        if (isset($data['position'])) $leaderboardSnapshot->setPosition($data['position']);
        if (isset($data['rating'])) $leaderboardSnapshot->setRating($data['rating']);
        if (isset($data['seasonPoints'])) $leaderboardSnapshot->setSeasonPoints($data['seasonPoints']);
        if (isset($data['entry'])) {
            $rel_entry = $this->leaderboardEntryRepository->find($data['entry']);
            if (!$rel_entry) return $this->json(['error' => 'LeaderboardEntry not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $leaderboardSnapshot->setEntry($rel_entry);
        }

        $errors = $this->validator->validate($leaderboardSnapshot);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($leaderboardSnapshot, flush: true);
        return $this->json($leaderboardSnapshot, context: ['groups' => ['leaderboardSnapshot:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(LeaderboardSnapshot $leaderboardSnapshot): JsonResponse
    {
        $this->repository->remove($leaderboardSnapshot, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
