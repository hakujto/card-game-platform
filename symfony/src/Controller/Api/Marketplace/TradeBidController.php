<?php

namespace App\Controller\Api\Marketplace;

use App\Entity\Marketplace\TradeBid;
use App\Repository\Marketplace\TradeBidRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Marketplace\Tradelisting;
use App\Repository\Marketplace\TradelistingRepository;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/trade_bids', name: 'tradeBid_')]
class TradeBidController extends AbstractController
{
    public function __construct(
        private TradeBidRepository $repository,
        private ValidatorInterface $validator,
        private TradelistingRepository $tradelistingRepository,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['tradeBid:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $tradeBid = new TradeBid();
        if (isset($data['amount'])) $tradeBid->setAmount($data['amount']);
        if (isset($data['placedAt'])) $tradeBid->setPlacedAt(new \DateTime($data['placedAt']));
        if (isset($data['isWinning'])) $tradeBid->setIsWinning($data['isWinning']);
        if (!isset($data['listing'])) return $this->json(['error' => 'listing is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_listing = $this->tradelistingRepository->find($data['listing']);
        if (!$rel_listing) return $this->json(['error' => 'TradeListing not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tradeBid->setListing($rel_listing);
        if (!isset($data['bidder'])) return $this->json(['error' => 'bidder is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_bidder = $this->playerRepository->find($data['bidder']);
        if (!$rel_bidder) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $tradeBid->setBidder($rel_bidder);

        $errors = $this->validator->validate($tradeBid);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tradeBid, flush: true);
        return $this->json($tradeBid, Response::HTTP_CREATED, context: ['groups' => ['tradeBid:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(TradeBid $tradeBid): JsonResponse
    {
        return $this->json($tradeBid, context: ['groups' => ['tradeBid:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, TradeBid $tradeBid): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['amount'])) $tradeBid->setAmount($data['amount']);
        if (isset($data['placedAt'])) $tradeBid->setPlacedAt(new \DateTime($data['placedAt']));
        if (isset($data['isWinning'])) $tradeBid->setIsWinning($data['isWinning']);
        if (isset($data['listing'])) {
            $rel_listing = $this->tradelistingRepository->find($data['listing']);
            if (!$rel_listing) return $this->json(['error' => 'TradeListing not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tradeBid->setListing($rel_listing);
        }
        if (isset($data['bidder'])) {
            $rel_bidder = $this->playerRepository->find($data['bidder']);
            if (!$rel_bidder) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $tradeBid->setBidder($rel_bidder);
        }

        $errors = $this->validator->validate($tradeBid);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($tradeBid, flush: true);
        return $this->json($tradeBid, context: ['groups' => ['tradeBid:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(TradeBid $tradeBid): JsonResponse
    {
        $this->repository->remove($tradeBid, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

}
