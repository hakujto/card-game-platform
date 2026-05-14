<?php

namespace App\Controller\Api\Marketplace;

use App\Entity\Marketplace\Order;
use App\Repository\Marketplace\OrderRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;
use App\Entity\Marketplace\Coupon;
use App\Repository\Marketplace\CouponRepository;

#[Route('/api/orders', name: 'order_')]
class OrderController extends AbstractController
{
    public function __construct(
        private OrderRepository $repository,
        private ValidatorInterface $validator,
        private PlayerRepository $playerRepository,
        private CouponRepository $couponRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['order:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $order = new Order();
        if (isset($data['status'])) $order->setStatus($data['status']);
        if (isset($data['total'])) $order->setTotal($data['total']);
        if (isset($data['discountApplied'])) $order->setDiscountApplied($data['discountApplied']);
        if (isset($data['currency'])) $order->setCurrency($data['currency']);
        if (isset($data['paymentMethod'])) $order->setPaymentMethod($data['paymentMethod']);
        if (isset($data['paymentReference'])) $order->setPaymentReference($data['paymentReference']);
        if (isset($data['shippingAddress'])) $order->setShippingAddress($data['shippingAddress']);
        if (isset($data['trackingNumber'])) $order->setTrackingNumber($data['trackingNumber']);
        if (isset($data['createdAt'])) $order->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['paidAt'])) $order->setPaidAt(new \DateTime($data['paidAt']));
        if (isset($data['shippedAt'])) $order->setShippedAt(new \DateTime($data['shippedAt']));
        if (!isset($data['player'])) return $this->json(['error' => 'player is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_player = $this->playerRepository->find($data['player']);
        if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $order->setPlayer($rel_player);
        if (array_key_exists('coupon', $data)) {
            $order->setCoupon($data['coupon'] !== null ? $this->couponRepository->find($data['coupon']) : null);
        }

        $errors = $this->validator->validate($order);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $order->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($order, flush: true);
        return $this->json($order, Response::HTTP_CREATED, context: ['groups' => ['order:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Order $order): JsonResponse
    {
        return $this->json($order, context: ['groups' => ['order:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Order $order): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['status'])) $order->setStatus($data['status']);
        if (isset($data['total'])) $order->setTotal($data['total']);
        if (isset($data['discountApplied'])) $order->setDiscountApplied($data['discountApplied']);
        if (isset($data['currency'])) $order->setCurrency($data['currency']);
        if (isset($data['paymentMethod'])) $order->setPaymentMethod($data['paymentMethod']);
        if (isset($data['paymentReference'])) $order->setPaymentReference($data['paymentReference']);
        if (isset($data['shippingAddress'])) $order->setShippingAddress($data['shippingAddress']);
        if (isset($data['trackingNumber'])) $order->setTrackingNumber($data['trackingNumber']);
        if (isset($data['createdAt'])) $order->setCreatedAt(new \DateTime($data['createdAt']));
        if (isset($data['paidAt'])) $order->setPaidAt(new \DateTime($data['paidAt']));
        if (isset($data['shippedAt'])) $order->setShippedAt(new \DateTime($data['shippedAt']));
        if (isset($data['player'])) {
            $rel_player = $this->playerRepository->find($data['player']);
            if (!$rel_player) return $this->json(['error' => 'Player not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $order->setPlayer($rel_player);
        }
        if (array_key_exists('coupon', $data)) {
            $order->setCoupon($data['coupon'] !== null ? $this->couponRepository->find($data['coupon']) : null);
        }

        $errors = $this->validator->validate($order);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $order->validateImplies();
        } catch (\DomainException $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($order, flush: true);
        return $this->json($order, context: ['groups' => ['order:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Order $order): JsonResponse
    {
        $this->repository->remove($order, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/cancel', name: 'cancel', methods: ['DELETE'])]
    public function cancel(Order $order): JsonResponse
    {
        $order->cancel();
        $this->repository->save($order, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/pay', name: 'pay', methods: ['POST'])]
    public function pay(Order $order, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $result = $order->pay($data['paymentRef'] ?? null);
        $this->repository->save($order, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/total', name: 'calculateTotal', methods: ['GET'])]
    public function calculateTotal(Order $order): JsonResponse
    {
        $result = $order->calculateTotal();
        $this->repository->save($order, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/discount', name: 'applyDiscount', methods: ['PATCH'])]
    public function applyDiscount(Order $order, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $result = $order->applyDiscount($data['percent'] ?? null);
        $this->repository->save($order, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/refund', name: 'refund', methods: ['POST'])]
    public function refund(Order $order): JsonResponse
    {
        $order->refund();
        $this->repository->save($order, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
