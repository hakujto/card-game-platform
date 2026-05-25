<?php

namespace App\Controller\Api\Marketplace;

use App\Entity\Marketplace\TradeTransaction;
use App\Repository\Marketplace\TradeTransactionRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Marketplace\TradeListing;
use App\Repository\Marketplace\TradeListingRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/trade_transactions', name: 'tradeTransaction_')]
class TradeTransactionController extends AbstractController
{
    public function __construct(
        private TradeTransactionRepository $repository,
        private ValidatorInterface $validator,
        private TradeListingRepository $tradeListingRepository,
        private PlayerRepository $playerRepository,
    ) {}


    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['tradeTransaction:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(TradeTransaction $tradeTransaction): JsonResponse
    {
        return $this->json($tradeTransaction, context: ['groups' => ['tradeTransaction:read']]);
    }

    #[Route('/{id}/complete', name: 'complete', methods: ['POST'])]
    public function complete(TradeTransaction $tradeTransaction): JsonResponse
    {
        $tradeTransaction->complete();
        $this->repository->save($tradeTransaction, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/refund', name: 'refund', methods: ['POST'])]
    public function refund(TradeTransaction $tradeTransaction): JsonResponse
    {
        $tradeTransaction->refund();
        $this->repository->save($tradeTransaction, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/dispute', name: 'openDispute', methods: ['POST'])]
    public function openDispute(TradeTransaction $tradeTransaction, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tradeTransaction->openDispute($data['reason'] ?? null);
        $this->repository->save($tradeTransaction, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/seller-net', name: 'sellerNet', methods: ['GET'])]
    public function sellerNet(TradeTransaction $tradeTransaction): JsonResponse
    {
        $result = $tradeTransaction->sellerNet();
        $this->repository->save($tradeTransaction, flush: true);
        return $this->json($result);
    }
}
