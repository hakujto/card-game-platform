<?php

namespace App\Controller\Api\Moderation;

use App\Entity\Moderation\PlayerReport;
use App\Repository\Moderation\PlayerReportRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Tournaments\MatchRecord;
use App\Repository\Tournaments\MatchRecordRepository;

#[Route('/api/player_reports', name: 'playerReport_')]
class PlayerReportController extends AbstractController
{
    public function __construct(
        private PlayerReportRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private MatchRecordRepository $matchRecordRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['playerReport:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $playerReport = new PlayerReport();
        if (isset($data['reason'])) $playerReport->setReason($data['reason']);
        if (isset($data['description'])) $playerReport->setDescription($data['description']);
        if (isset($data['status'])) $playerReport->setStatus($data['status']);
        if (isset($data['createdAt'])) $playerReport->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['reviewedAt'])) $playerReport->setReviewedAt(new \DateTime($data['reviewedAt']));
        if (!isset($data['reportedPlayer'])) return $this->json(['error' => 'reportedPlayer is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_reportedPlayer = $this->playerRepository->find($data['reportedPlayer']);
        if (!$rel_reportedPlayer) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $playerReport->setReportedPlayer($rel_reportedPlayer);
        if (!isset($data['reporter'])) return $this->json(['error' => 'reporter is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_reporter = $this->playerRepository->find($data['reporter']);
        if (!$rel_reporter) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $playerReport->setReporter($rel_reporter);
        if (array_key_exists('reviewedBy', $data)) {
            $playerReport->setReviewedBy($data['reviewedBy'] !== null ? $this->playerRepository->find($data['reviewedBy']) : null);
        }
        if (array_key_exists('match', $data)) {
            $playerReport->setMatch($data['match'] !== null ? $this->matchRecordRepository->find($data['match']) : null);
        }

        $errors = $this->validator->validate($playerReport);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($playerReport, flush: true);
        return $this->json($playerReport, Response::HTTP_CREATED, context: ['groups' => ['playerReport:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(PlayerReport $playerReport): JsonResponse
    {
        return $this->json($playerReport, context: ['groups' => ['playerReport:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, PlayerReport $playerReport): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['reason'])) $playerReport->setReason($data['reason']);
        if (isset($data['description'])) $playerReport->setDescription($data['description']);
        if (isset($data['status'])) $playerReport->setStatus($data['status']);
        if (isset($data['createdAt'])) $playerReport->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['reviewedAt'])) $playerReport->setReviewedAt(new \DateTime($data['reviewedAt']));
        if (isset($data['reportedPlayer'])) {
            $rel_reportedPlayer = $this->playerRepository->find($data['reportedPlayer']);
            if (!$rel_reportedPlayer) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $playerReport->setReportedPlayer($rel_reportedPlayer);
        }
        if (isset($data['reporter'])) {
            $rel_reporter = $this->playerRepository->find($data['reporter']);
            if (!$rel_reporter) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $playerReport->setReporter($rel_reporter);
        }
        if (array_key_exists('reviewedBy', $data)) {
            $playerReport->setReviewedBy($data['reviewedBy'] !== null ? $this->playerRepository->find($data['reviewedBy']) : null);
        }
        if (array_key_exists('match', $data)) {
            $playerReport->setMatch($data['match'] !== null ? $this->matchRecordRepository->find($data['match']) : null);
        }

        $errors = $this->validator->validate($playerReport);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($playerReport, flush: true);
        return $this->json($playerReport, context: ['groups' => ['playerReport:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(PlayerReport $playerReport): JsonResponse
    {
        $this->repository->remove($playerReport, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
