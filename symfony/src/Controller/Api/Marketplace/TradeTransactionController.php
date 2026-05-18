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

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tradeTransaction = new TradeTransaction();
        if (isset($data['finalPrice'])) $tradeTransaction->setFinalPrice($data['finalPrice']);
        if (isset($data['platformFee'])) $tradeTransaction->setPlatformFee($data['platformFee']);
        if (isset($data['status'])) $tradeTransaction->setStatus($data['status']);
        if (isset($data['completedAt'])) $tradeTransaction->setCompletedAt(new \DateTime($data['completedAt']));
        if (!isset($data['listing'])) return $this->json(['error' => 'listing is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_listing = $this->tradeListingRepository->find($data['listing']);
        if (!$rel_listing) return $this->json(['error' => 'TradeListing not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tradeTransaction->setListing($rel_listing);
        if (!isset($data['buyer'])) return $this->json(['error' => 'buyer is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_buyer = $this->playerRepository->find($data['buyer']);
        if (!$rel_buyer) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tradeTransaction->setBuyer($rel_buyer);
        if (!isset($data['seller'])) return $this->json(['error' => 'seller is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_seller = $this->playerRepository->find($data['seller']);
        if (!$rel_seller) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tradeTransaction->setSeller($rel_seller);

        $errors = $this->validator->validate($tradeTransaction);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $tradeTransaction->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tradeTransaction, flush: true);
        return $this->json($tradeTransaction, Response::HTTP_CREATED, context: ['groups' => ['tradeTransaction:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(TradeTransaction $tradeTransaction): JsonResponse
    {
        return $this->json($tradeTransaction, context: ['groups' => ['tradeTransaction:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, TradeTransaction $tradeTransaction): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['finalPrice'])) $tradeTransaction->setFinalPrice($data['finalPrice']);
        if (isset($data['platformFee'])) $tradeTransaction->setPlatformFee($data['platformFee']);
        if (isset($data['status'])) $tradeTransaction->setStatus($data['status']);
        if (isset($data['completedAt'])) $tradeTransaction->setCompletedAt(new \DateTime($data['completedAt']));
        if (isset($data['listing'])) {
            $rel_listing = $this->tradeListingRepository->find($data['listing']);
            if (!$rel_listing) return $this->json(['error' => 'TradeListing not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tradeTransaction->setListing($rel_listing);
        }
        if (isset($data['buyer'])) {
            $rel_buyer = $this->playerRepository->find($data['buyer']);
            if (!$rel_buyer) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tradeTransaction->setBuyer($rel_buyer);
        }
        if (isset($data['seller'])) {
            $rel_seller = $this->playerRepository->find($data['seller']);
            if (!$rel_seller) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tradeTransaction->setSeller($rel_seller);
        }

        $errors = $this->validator->validate($tradeTransaction);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $tradeTransaction->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tradeTransaction, flush: true);
        return $this->json($tradeTransaction, context: ['groups' => ['tradeTransaction:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(TradeTransaction $tradeTransaction): JsonResponse
    {
        $this->repository->remove($tradeTransaction, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
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
