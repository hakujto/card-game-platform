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

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $cardPriceHistory = new CardPriceHistory();
        if (isset($data['priceDate'])) $cardPriceHistory->setPriceDate(new \DateTime($data['priceDate']));
        if (isset($data['avgPrice'])) $cardPriceHistory->setAvgPrice($data['avgPrice']);
        if (isset($data['minPrice'])) $cardPriceHistory->setMinPrice($data['minPrice']);
        if (isset($data['maxPrice'])) $cardPriceHistory->setMaxPrice($data['maxPrice']);
        if (isset($data['volume'])) $cardPriceHistory->setVolume($data['volume']);
        if (isset($data['foil'])) $cardPriceHistory->setFoil($data['foil']);
        if (!isset($data['card'])) return $this->json(['error' => 'card is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_card = $this->cardRepository->find($data['card']);
        if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $cardPriceHistory->setCard($rel_card);

        $errors = $this->validator->validate($cardPriceHistory);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($cardPriceHistory, flush: true);
        return $this->json($cardPriceHistory, Response::HTTP_CREATED, context: ['groups' => ['cardPriceHistory:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(CardPriceHistory $cardPriceHistory): JsonResponse
    {
        return $this->json($cardPriceHistory, context: ['groups' => ['cardPriceHistory:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, CardPriceHistory $cardPriceHistory): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['priceDate'])) $cardPriceHistory->setPriceDate(new \DateTime($data['priceDate']));
        if (isset($data['avgPrice'])) $cardPriceHistory->setAvgPrice($data['avgPrice']);
        if (isset($data['minPrice'])) $cardPriceHistory->setMinPrice($data['minPrice']);
        if (isset($data['maxPrice'])) $cardPriceHistory->setMaxPrice($data['maxPrice']);
        if (isset($data['volume'])) $cardPriceHistory->setVolume($data['volume']);
        if (isset($data['foil'])) $cardPriceHistory->setFoil($data['foil']);
        if (isset($data['card'])) {
            $rel_card = $this->cardRepository->find($data['card']);
            if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $cardPriceHistory->setCard($rel_card);
        }

        $errors = $this->validator->validate($cardPriceHistory);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($cardPriceHistory, flush: true);
        return $this->json($cardPriceHistory, context: ['groups' => ['cardPriceHistory:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(CardPriceHistory $cardPriceHistory): JsonResponse
    {
        $this->repository->remove($cardPriceHistory, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
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
