<?php

namespace App\Controller\Api\Marketplace;

use App\Entity\Marketplace\TradeDispute;
use App\Repository\Marketplace\TradeDisputeRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Marketplace\TradeTransaction;
use App\Repository\Marketplace\TradeTransactionRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/trade_disputes', name: 'tradeDispute_')]
class TradeDisputeController extends AbstractController
{
    public function __construct(
        private TradeDisputeRepository $repository,
        private ValidatorInterface $validator,
        private TradeTransactionRepository $tradeTransactionRepository,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['tradeDispute:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tradeDispute = new TradeDispute();
        if (isset($data['reason'])) $tradeDispute->setReason($data['reason']);
        if (isset($data['description'])) $tradeDispute->setDescription($data['description']);
        if (isset($data['status'])) $tradeDispute->setStatus($data['status']);
        if (isset($data['resolution'])) $tradeDispute->setResolution($data['resolution']);
        if (isset($data['openedAt'])) $tradeDispute->setOpenedAt(new \DateTime($data['openedAt']));
        if (isset($data['resolvedAt'])) $tradeDispute->setResolvedAt(new \DateTime($data['resolvedAt']));
        if (!isset($data['transaction'])) return $this->json(['error' => 'transaction is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_transaction = $this->tradeTransactionRepository->find($data['transaction']);
        if (!$rel_transaction) return $this->json(['error' => 'TradeTransaction not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tradeDispute->setTransaction($rel_transaction);
        if (!isset($data['openedBy'])) return $this->json(['error' => 'openedBy is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_openedBy = $this->playerRepository->find($data['openedBy']);
        if (!$rel_openedBy) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tradeDispute->setOpenedBy($rel_openedBy);
        if (array_key_exists('resolvedBy', $data)) {
            $tradeDispute->setResolvedBy($data['resolvedBy'] !== null ? $this->playerRepository->find($data['resolvedBy']) : null);
        }

        $errors = $this->validator->validate($tradeDispute);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $tradeDispute->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tradeDispute, flush: true);
        return $this->json($tradeDispute, Response::HTTP_CREATED, context: ['groups' => ['tradeDispute:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(TradeDispute $tradeDispute): JsonResponse
    {
        return $this->json($tradeDispute, context: ['groups' => ['tradeDispute:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, TradeDispute $tradeDispute): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['reason'])) $tradeDispute->setReason($data['reason']);
        if (isset($data['description'])) $tradeDispute->setDescription($data['description']);
        if (isset($data['status'])) $tradeDispute->setStatus($data['status']);
        if (isset($data['resolution'])) $tradeDispute->setResolution($data['resolution']);
        if (isset($data['openedAt'])) $tradeDispute->setOpenedAt(new \DateTime($data['openedAt']));
        if (isset($data['resolvedAt'])) $tradeDispute->setResolvedAt(new \DateTime($data['resolvedAt']));
        if (isset($data['transaction'])) {
            $rel_transaction = $this->tradeTransactionRepository->find($data['transaction']);
            if (!$rel_transaction) return $this->json(['error' => 'TradeTransaction not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tradeDispute->setTransaction($rel_transaction);
        }
        if (isset($data['openedBy'])) {
            $rel_openedBy = $this->playerRepository->find($data['openedBy']);
            if (!$rel_openedBy) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tradeDispute->setOpenedBy($rel_openedBy);
        }
        if (array_key_exists('resolvedBy', $data)) {
            $tradeDispute->setResolvedBy($data['resolvedBy'] !== null ? $this->playerRepository->find($data['resolvedBy']) : null);
        }

        $errors = $this->validator->validate($tradeDispute);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $tradeDispute->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tradeDispute, flush: true);
        return $this->json($tradeDispute, context: ['groups' => ['tradeDispute:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(TradeDispute $tradeDispute): JsonResponse
    {
        $this->repository->remove($tradeDispute, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/escalate', name: 'escalate', methods: ['POST'])]
    public function escalate(TradeDispute $tradeDispute): JsonResponse
    {
        $tradeDispute->escalate();
        $this->repository->save($tradeDispute, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/resolve', name: 'resolve', methods: ['POST'])]
    public function resolve(TradeDispute $tradeDispute, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tradeDispute->resolve($data['resolutionText'] ?? null);
        $this->repository->save($tradeDispute, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/review', name: 'review', methods: ['POST'])]
    public function review(TradeDispute $tradeDispute): JsonResponse
    {
        $tradeDispute->review();
        $this->repository->save($tradeDispute, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
