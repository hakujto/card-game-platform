<?php

namespace App\Controller\Api\Economy;

use App\Entity\Economy\Wallet;
use App\Repository\Economy\WalletRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/wallets', name: 'wallet_')]
class WalletController extends AbstractController
{
    public function __construct(
        private WalletRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['wallet:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $wallet = new Wallet();
        if (isset($data['creditsBalance'])) $wallet->setCreditsBalance($data['creditsBalance']);
        if (isset($data['dustBalance'])) $wallet->setDustBalance($data['dustBalance']);
        if (isset($data['gemsBalance'])) $wallet->setGemsBalance($data['gemsBalance']);
        if (isset($data['updatedAt'])) $wallet->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $wallet->setPlayer($rel_player);

        $errors = $this->validator->validate($wallet);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($wallet, flush: true);
        return $this->json($wallet, Response::HTTP_CREATED, context: ['groups' => ['wallet:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Wallet $wallet): JsonResponse
    {
        return $this->json($wallet, context: ['groups' => ['wallet:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Wallet $wallet): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['creditsBalance'])) $wallet->setCreditsBalance($data['creditsBalance']);
        if (isset($data['dustBalance'])) $wallet->setDustBalance($data['dustBalance']);
        if (isset($data['gemsBalance'])) $wallet->setGemsBalance($data['gemsBalance']);
        if (isset($data['updatedAt'])) $wallet->setUpdatedAt(new \DateTime($data['updatedAt']));
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $wallet->setPlayer($rel_player);
        }

        $errors = $this->validator->validate($wallet);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($wallet, flush: true);
        return $this->json($wallet, context: ['groups' => ['wallet:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Wallet $wallet): JsonResponse
    {
        $this->repository->remove($wallet, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
