<?php

namespace App\Controller\Api\Economy;

use App\Entity\Economy\WalletTransaction;
use App\Repository\Economy\WalletTransactionRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Economy\Wallet;
use App\Repository\Economy\WalletRepository;
use App\Entity\Marketplace\Order;
use App\Repository\Marketplace\OrderRepository;
use App\Entity\Marketplace\TradeTransaction;
use App\Repository\Marketplace\TradeTransactionRepository;

#[Route('/api/wallet_transactions', name: 'walletTransaction_')]
class WalletTransactionController extends AbstractController
{
    public function __construct(
        private WalletTransactionRepository $repository,
        private ValidatorInterface $validator,
        private WalletRepository $walletRepository,
        private OrderRepository $orderRepository,
        private TradeTransactionRepository $tradeTransactionRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['walletTransaction:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $walletTransaction = new WalletTransaction();
        if (isset($data['transactionType'])) $walletTransaction->setTransactionType($data['transactionType']);
        if (isset($data['currency'])) $walletTransaction->setCurrency($data['currency']);
        if (isset($data['amount'])) $walletTransaction->setAmount($data['amount']);
        if (isset($data['balanceAfter'])) $walletTransaction->setBalanceAfter($data['balanceAfter']);
        if (isset($data['description'])) $walletTransaction->setDescription($data['description']);
        if (isset($data['createdAt'])) $walletTransaction->setCreatedAt(new \DateTime($data['createdAt']));
        if (!isset($data['wallet'])) return $this->json(['error' => 'wallet is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_wallet = $this->walletRepository->find($data['wallet']);
        if (!$rel_wallet) return $this->json(['error' => 'Wallet not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $walletTransaction->setWallet($rel_wallet);
        if (array_key_exists('order', $data)) {
            $walletTransaction->setOrder($data['order'] !== null ? $this->orderRepository->find($data['order']) : null);
        }
        if (array_key_exists('tradeTransaction', $data)) {
            $walletTransaction->setTradeTransaction($data['tradeTransaction'] !== null ? $this->tradeTransactionRepository->find($data['tradeTransaction']) : null);
        }

        $errors = $this->validator->validate($walletTransaction);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($walletTransaction, flush: true);
        return $this->json($walletTransaction, Response::HTTP_CREATED, context: ['groups' => ['walletTransaction:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(WalletTransaction $walletTransaction): JsonResponse
    {
        return $this->json($walletTransaction, context: ['groups' => ['walletTransaction:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, WalletTransaction $walletTransaction): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['transactionType'])) $walletTransaction->setTransactionType($data['transactionType']);
        if (isset($data['currency'])) $walletTransaction->setCurrency($data['currency']);
        if (isset($data['amount'])) $walletTransaction->setAmount($data['amount']);
        if (isset($data['balanceAfter'])) $walletTransaction->setBalanceAfter($data['balanceAfter']);
        if (isset($data['description'])) $walletTransaction->setDescription($data['description']);
        if (isset($data['createdAt'])) $walletTransaction->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['wallet'])) {
            $rel_wallet = $this->walletRepository->find($data['wallet']);
            if (!$rel_wallet) return $this->json(['error' => 'Wallet not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $walletTransaction->setWallet($rel_wallet);
        }
        if (array_key_exists('order', $data)) {
            $walletTransaction->setOrder($data['order'] !== null ? $this->orderRepository->find($data['order']) : null);
        }
        if (array_key_exists('tradeTransaction', $data)) {
            $walletTransaction->setTradeTransaction($data['tradeTransaction'] !== null ? $this->tradeTransactionRepository->find($data['tradeTransaction']) : null);
        }

        $errors = $this->validator->validate($walletTransaction);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($walletTransaction, flush: true);
        return $this->json($walletTransaction, context: ['groups' => ['walletTransaction:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(WalletTransaction $walletTransaction): JsonResponse
    {
        $this->repository->remove($walletTransaction, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
