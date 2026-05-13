<?php

namespace App\Controller\Api\Marketplace;

use App\Entity\Marketplace\Tradelisting;
use App\Repository\Marketplace\TradelistingRepository;
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
use App\Entity\Marketplace\TradeBid;
use App\Repository\Marketplace\TradeBidRepository;

#[Route('/api/tradelistings', name: 'tradelisting_')]
class TradelistingController extends AbstractController
{
    public function __construct(
        private TradelistingRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private CardRepository $cardRepository,
        private TradeBidRepository $tradeBidRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['tradelisting:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tradelisting = new Tradelisting();
        if (isset($data['listingType'])) $tradelisting->setListingType($data['listingType']);
        if (isset($data['askingPrice'])) $tradelisting->setAskingPrice($data['askingPrice']);
        if (isset($data['auctionStartPrice'])) $tradelisting->setAuctionStartPrice($data['auctionStartPrice']);
        if (isset($data['auctionCurrentBid'])) $tradelisting->setAuctionCurrentBid($data['auctionCurrentBid']);
        if (isset($data['auctionEndTime'])) $tradelisting->setAuctionEndTime(new \DateTime($data['auctionEndTime']));
        if (isset($data['foil'])) $tradelisting->setFoil($data['foil']);
        if (isset($data['condition'])) $tradelisting->setCondition($data['condition']);
        if (isset($data['quantity'])) $tradelisting->setQuantity($data['quantity']);
        if (isset($data['status'])) $tradelisting->setStatus($data['status']);
        if (isset($data['description'])) $tradelisting->setDescription($data['description']);
        if (isset($data['createdAt'])) $tradelisting->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['expiresAt'])) $tradelisting->setExpiresAt(new \DateTime($data['expiresAt']));
        if (!isset($data['seller'])) return $this->json(['error' => 'seller is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_seller = $this->playerRepository->find($data['seller']);
        if (!$rel_seller) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tradelisting->setSeller($rel_seller);
        if (!isset($data['card'])) return $this->json(['error' => 'card is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_card = $this->cardRepository->find($data['card']);
        if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tradelisting->setCard($rel_card);
        if (array_key_exists('bids', $data)) {
            $tradelisting->setBids($data['bids'] !== null ? $this->tradeBidRepository->find($data['bids']) : null);
        }

        $errors = $this->validator->validate($tradelisting);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tradelisting, flush: true);
        return $this->json($tradelisting, Response::HTTP_CREATED, context: ['groups' => ['tradelisting:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Tradelisting $tradelisting): JsonResponse
    {
        return $this->json($tradelisting, context: ['groups' => ['tradelisting:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Tradelisting $tradelisting): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['listingType'])) $tradelisting->setListingType($data['listingType']);
        if (isset($data['askingPrice'])) $tradelisting->setAskingPrice($data['askingPrice']);
        if (isset($data['auctionStartPrice'])) $tradelisting->setAuctionStartPrice($data['auctionStartPrice']);
        if (isset($data['auctionCurrentBid'])) $tradelisting->setAuctionCurrentBid($data['auctionCurrentBid']);
        if (isset($data['auctionEndTime'])) $tradelisting->setAuctionEndTime(new \DateTime($data['auctionEndTime']));
        if (isset($data['foil'])) $tradelisting->setFoil($data['foil']);
        if (isset($data['condition'])) $tradelisting->setCondition($data['condition']);
        if (isset($data['quantity'])) $tradelisting->setQuantity($data['quantity']);
        if (isset($data['status'])) $tradelisting->setStatus($data['status']);
        if (isset($data['description'])) $tradelisting->setDescription($data['description']);
        if (isset($data['createdAt'])) $tradelisting->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['expiresAt'])) $tradelisting->setExpiresAt(new \DateTime($data['expiresAt']));
        if (isset($data['seller'])) {
            $rel_seller = $this->playerRepository->find($data['seller']);
            if (!$rel_seller) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tradelisting->setSeller($rel_seller);
        }
        if (isset($data['card'])) {
            $rel_card = $this->cardRepository->find($data['card']);
            if (!$rel_card) return $this->json(['error' => 'Card not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tradelisting->setCard($rel_card);
        }
        if (array_key_exists('bids', $data)) {
            $tradelisting->setBids($data['bids'] !== null ? $this->tradeBidRepository->find($data['bids']) : null);
        }

        $errors = $this->validator->validate($tradelisting);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tradelisting, flush: true);
        return $this->json($tradelisting, context: ['groups' => ['tradelisting:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Tradelisting $tradelisting): JsonResponse
    {
        $this->repository->remove($tradelisting, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/close', name: 'close', methods: ['POST'])]
    public function close(Tradelisting $tradelisting): JsonResponse
    {
        $tradelisting->close();
        $this->repository->save($tradelisting, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/extend', name: 'extend', methods: ['PATCH'])]
    public function extend(Tradelisting $tradelisting, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tradelisting->extend($data['days'] ?? null);
        $this->repository->save($tradelisting, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/cancel', name: 'cancel', methods: ['DELETE'])]
    public function cancel(Tradelisting $tradelisting): JsonResponse
    {
        $tradelisting->cancel();
        $this->repository->save($tradelisting, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
