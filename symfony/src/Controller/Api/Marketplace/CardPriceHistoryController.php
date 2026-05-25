<?php

namespace App\Controller\Api\Marketplace;

use App\Entity\Marketplace\CardPriceHistory;
use App\Repository\Marketplace\CardPriceHistoryRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;

#[Route('/api/card_price_histories', name: 'cardPriceHistory_')]
class CardPriceHistoryController extends AbstractController
{
    public function __construct(
        private CardPriceHistoryRepository $repository,
        private ValidatorInterface $validator,
        private CardRepository $cardRepository,
    ) {}


    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['cardPriceHistory:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(CardPriceHistory $cardPriceHistory): JsonResponse
    {
        return $this->json($cardPriceHistory, context: ['groups' => ['cardPriceHistory:read']]);
    }

    #[Route('/{id}/change', name: 'priceChangePercent', methods: ['GET'])]
    public function priceChangePercent(CardPriceHistory $cardPriceHistory): JsonResponse
    {
        $result = $cardPriceHistory->priceChangePercent($previousAvg);
        $this->repository->save($cardPriceHistory, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/spike', name: 'isPriceSpike', methods: ['GET'])]
    public function isPriceSpike(CardPriceHistory $cardPriceHistory): JsonResponse
    {
        $result = $cardPriceHistory->isPriceSpike($thresholdPercent);
        $this->repository->save($cardPriceHistory, flush: true);
        return $this->json($result);
    }
}
