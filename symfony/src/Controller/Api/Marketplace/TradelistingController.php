<?php

namespace App\Controller\Api\Marketplace;

use App\Entity\Marketplace\TradeListing;
use App\Repository\Marketplace\TradeListingRepository;
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

#[Route('/api/trade_listings', name: 'tradeListing_')]
class TradeListingController extends AbstractController
{
    public function __construct(
        private TradeListingRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private CardRepository $cardRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['tradeListing:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tradeListing = new TradeListing();
        if (isset($data['listingType'])) $tradeListing->setListingType($data['listingType']);
        if (isset($data['askingPrice'])) $tradeListing->setAskingPrice($data['askingPrice']);
        if (isset($data['auctionStartPrice'])) $tradeListing->setAuctionStartPrice($data['auctionStartPrice']);
        if (isset($data['auctionCurrentBid'])) $tradeListing->setAuctionCurrentBid($data['auctionCurrentBid']);
        if (isset($data['auctionEndTime'])) $tradeListing->setAuctionEndTime(new \DateTime($data['auctionEndTime']));
        if (isset($data['foil'])) $tradeListing->setFoil($data['foil']);
        if (isset($data['condition'])) $tradeListing->setCondition($data['condition']);
        if (isset($data['quantity'])) $tradeListing->setQuantity($data['quantity']);
        if (isset($data['status'])) $tradeListing->setStatus($data['status']);
        if (isset($data['description'])) $tradeListing->setDescription($data['description']);
        if (isset($data['createdAt'])) $tradeListing->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['expiresAt'])) $tradeListing->setExpiresAt(new \DateTime($data['expiresAt']));
        if (!isset($data['seller'])) return $this->json(['error' => 'seller is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_seller = $this->playerRepository->find($data['seller']);
        if (!$rel_seller) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tradeListing->setSeller($rel_seller);
        if (!isset($data['card'])) return $this->json(['error' => 'card is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_card = $this->cardRepository->find($data['card']);
        if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tradeListing->setCard($rel_card);

        $errors = $this->validator->validate($tradeListing);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $tradeListing->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tradeListing, flush: true);
        return $this->json($tradeListing, Response::HTTP_CREATED, context: ['groups' => ['tradeListing:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(TradeListing $tradeListing): JsonResponse
    {
        return $this->json($tradeListing, context: ['groups' => ['tradeListing:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, TradeListing $tradeListing): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['listingType'])) $tradeListing->setListingType($data['listingType']);
        if (isset($data['askingPrice'])) $tradeListing->setAskingPrice($data['askingPrice']);
        if (isset($data['auctionStartPrice'])) $tradeListing->setAuctionStartPrice($data['auctionStartPrice']);
        if (isset($data['auctionCurrentBid'])) $tradeListing->setAuctionCurrentBid($data['auctionCurrentBid']);
        if (isset($data['auctionEndTime'])) $tradeListing->setAuctionEndTime(new \DateTime($data['auctionEndTime']));
        if (isset($data['foil'])) $tradeListing->setFoil($data['foil']);
        if (isset($data['condition'])) $tradeListing->setCondition($data['condition']);
        if (isset($data['quantity'])) $tradeListing->setQuantity($data['quantity']);
        if (isset($data['status'])) $tradeListing->setStatus($data['status']);
        if (isset($data['description'])) $tradeListing->setDescription($data['description']);
        if (isset($data['createdAt'])) $tradeListing->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['expiresAt'])) $tradeListing->setExpiresAt(new \DateTime($data['expiresAt']));
        if (isset($data['seller'])) {
            $rel_seller = $this->playerRepository->find($data['seller']);
            if (!$rel_seller) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tradeListing->setSeller($rel_seller);
        }
        if (isset($data['card'])) {
            $rel_card = $this->cardRepository->find($data['card']);
            if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tradeListing->setCard($rel_card);
        }

        $errors = $this->validator->validate($tradeListing);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $tradeListing->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tradeListing, flush: true);
        return $this->json($tradeListing, context: ['groups' => ['tradeListing:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(TradeListing $tradeListing): JsonResponse
    {
        $this->repository->remove($tradeListing, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/close', name: 'close', methods: ['POST'])]
    public function close(TradeListing $tradeListing): JsonResponse
    {
        $tradeListing->close();
        $this->repository->save($tradeListing, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/extend', name: 'extend', methods: ['PATCH'])]
    public function extend(TradeListing $tradeListing, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tradeListing->extend($data['days'] ?? null);
        $this->repository->save($tradeListing, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/cancel', name: 'cancel', methods: ['DELETE'])]
    public function cancel(TradeListing $tradeListing): JsonResponse
    {
        $tradeListing->cancel();
        $this->repository->save($tradeListing, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/expired', name: 'isExpired', methods: ['GET'])]
    public function isExpired(TradeListing $tradeListing): JsonResponse
    {
        $result = $tradeListing->isExpired();
        $this->repository->save($tradeListing, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/finalize', name: 'finalizeAuction', methods: ['POST'])]
    public function finalizeAuction(TradeListing $tradeListing): JsonResponse
    {
        $tradeListing->finalizeAuction();
        $this->repository->save($tradeListing, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
