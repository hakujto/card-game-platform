<?php

namespace App\Controller\Api\Economy;

use App\Entity\Economy\TopUpOrder;
use App\Repository\Economy\TopUpOrderRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

#[Route('/api/top_up_orders', name: 'topUpOrder_')]
class TopUpOrderController extends AbstractController
{
    public function __construct(
        private TopUpOrderRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['topUpOrder:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $topUpOrder = new TopUpOrder();
        if (isset($data['amountPaid'])) $topUpOrder->setAmountPaid($data['amountPaid']);
        if (isset($data['currencyPaid'])) $topUpOrder->setCurrencyPaid($data['currencyPaid']);
        if (isset($data['creditsGranted'])) $topUpOrder->setCreditsGranted($data['creditsGranted']);
        if (isset($data['gemsGranted'])) $topUpOrder->setGemsGranted($data['gemsGranted']);
        if (isset($data['paymentMethod'])) $topUpOrder->setPaymentMethod($data['paymentMethod']);
        if (isset($data['paymentReference'])) $topUpOrder->setPaymentReference($data['paymentReference']);
        if (isset($data['status'])) $topUpOrder->setStatus($data['status']);
        if (isset($data['createdAt'])) $topUpOrder->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['completedAt'])) $topUpOrder->setCompletedAt(new \DateTime($data['completedAt']));
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $topUpOrder->setPlayer($rel_player);

        $errors = $this->validator->validate($topUpOrder);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($topUpOrder, flush: true);
        return $this->json($topUpOrder, Response::HTTP_CREATED, context: ['groups' => ['topUpOrder:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(TopUpOrder $topUpOrder): JsonResponse
    {
        return $this->json($topUpOrder, context: ['groups' => ['topUpOrder:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, TopUpOrder $topUpOrder): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['amountPaid'])) $topUpOrder->setAmountPaid($data['amountPaid']);
        if (isset($data['currencyPaid'])) $topUpOrder->setCurrencyPaid($data['currencyPaid']);
        if (isset($data['creditsGranted'])) $topUpOrder->setCreditsGranted($data['creditsGranted']);
        if (isset($data['gemsGranted'])) $topUpOrder->setGemsGranted($data['gemsGranted']);
        if (isset($data['paymentMethod'])) $topUpOrder->setPaymentMethod($data['paymentMethod']);
        if (isset($data['paymentReference'])) $topUpOrder->setPaymentReference($data['paymentReference']);
        if (isset($data['status'])) $topUpOrder->setStatus($data['status']);
        if (isset($data['createdAt'])) $topUpOrder->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['completedAt'])) $topUpOrder->setCompletedAt(new \DateTime($data['completedAt']));
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $topUpOrder->setPlayer($rel_player);
        }

        $errors = $this->validator->validate($topUpOrder);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($topUpOrder, flush: true);
        return $this->json($topUpOrder, context: ['groups' => ['topUpOrder:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(TopUpOrder $topUpOrder): JsonResponse
    {
        $this->repository->remove($topUpOrder, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
