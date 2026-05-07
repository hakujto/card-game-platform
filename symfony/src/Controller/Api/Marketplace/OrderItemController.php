<?php

namespace App\Controller\Api\Marketplace;

use App\Entity\Marketplace\OrderItem;
use App\Repository\Marketplace\OrderItemRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Marketplace\Order;
use App\Repository\Marketplace\OrderRepository;
use App\Entity\Marketplace\Product;
use App\Repository\Marketplace\ProductRepository;

#[Route('/api/order_items', name: 'orderItem_')]
class OrderItemController extends AbstractController
{
    public function __construct(
        private OrderItemRepository $repository,
        private ValidatorInterface $validator,
        private OrderRepository $orderRepository,
        private ProductRepository $productRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['orderItem:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $orderItem = new OrderItem();
        if (isset($data['quantity'])) $orderItem->setQuantity($data['quantity']);
        if (isset($data['priceAtPurchase'])) $orderItem->setPriceAtPurchase($data['priceAtPurchase']);
        if (isset($data['foil'])) $orderItem->setFoil($data['foil']);
        if (array_key_exists('order', $data)) {
            $orderItem->setOrder($data['order'] !== null ? $this->orderRepository->find($data['order']) : null);
        }
        if (!isset($data['product'])) return $this->json(['error' => 'product is required'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $rel_product = $this->productRepository->find($data['product']);
        if (!$rel_product) return $this->json(['error' => 'Product not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
        $orderItem->setProduct($rel_product);

        $errors = $this->validator->validate($orderItem);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($orderItem, flush: true);
        return $this->json($orderItem, Response::HTTP_CREATED, context: ['groups' => ['orderItem:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(OrderItem $orderItem): JsonResponse
    {
        return $this->json($orderItem, context: ['groups' => ['orderItem:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, OrderItem $orderItem): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['quantity'])) $orderItem->setQuantity($data['quantity']);
        if (isset($data['priceAtPurchase'])) $orderItem->setPriceAtPurchase($data['priceAtPurchase']);
        if (isset($data['foil'])) $orderItem->setFoil($data['foil']);
        if (array_key_exists('order', $data)) {
            $orderItem->setOrder($data['order'] !== null ? $this->orderRepository->find($data['order']) : null);
        }
        if (isset($data['product'])) {
            $rel_product = $this->productRepository->find($data['product']);
            if (!$rel_product) return $this->json(['error' => 'Product not found'], Response::HTTP_UNPROCESSABLE_ENTITY);
            $orderItem->setProduct($rel_product);
        }

        $errors = $this->validator->validate($orderItem);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($orderItem, flush: true);
        return $this->json($orderItem, context: ['groups' => ['orderItem:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(OrderItem $orderItem): JsonResponse
    {
        $this->repository->remove($orderItem, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }
}
