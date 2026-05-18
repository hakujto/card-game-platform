<?php

namespace App\Controller\Api\Marketplace;

use App\Entity\Marketplace\Product;
use App\Repository\Marketplace\ProductRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;
use App\Entity\Cards\CardSet;
use App\Repository\Cards\CardSetRepository;

#[Route('/api/products', name: 'product_')]
class ProductController extends AbstractController
{
    public function __construct(
        private ProductRepository $repository,
        private ValidatorInterface $validator,
        private CardRepository $cardRepository,
        private CardSetRepository $cardSetRepository,
    ) {}

    #[Route('', name: 'list', methods: ['GET'])]
    public function list(): JsonResponse
    {
        $items = $this->repository->findAll();
        return $this->json($items, context: ['groups' => ['product:read']]);
    }

    #[Route('', name: 'create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $product = new Product();
        if (isset($data['name'])) $product->setName($data['name']);
        if (isset($data['productType'])) $product->setProductType($data['productType']);
        if (isset($data['price'])) $product->setPrice($data['price']);
        if (isset($data['stock'])) $product->setStock($data['stock']);
        if (isset($data['active'])) $product->setActive($data['active']);
        if (isset($data['discountPercent'])) $product->setDiscountPercent($data['discountPercent']);
        if (isset($data['description'])) $product->setDescription($data['description']);
        if (isset($data['imageUrl'])) $product->setImageUrl($data['imageUrl']);
        if (isset($data['featured'])) $product->setFeatured($data['featured']);
        if (array_key_exists('card', $data)) {
            $product->setCard($data['card'] !== null ? $this->cardRepository->find($data['card']) : null);
        }
        if (array_key_exists('cardSet', $data)) {
            $product->setCardSet($data['cardSet'] !== null ? $this->cardSetRepository->find($data['cardSet']) : null);
        }

        $errors = $this->validator->validate($product);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($product, flush: true);
        return $this->json($product, Response::HTTP_CREATED, context: ['groups' => ['product:read']]);
    }

    #[Route('/{id}', name: 'show', methods: ['GET'])]
    public function show(Product $product): JsonResponse
    {
        return $this->json($product, context: ['groups' => ['product:read']]);
    }

    #[Route('/{id}', name: 'update', methods: ['PUT', 'PATCH'])]
    public function update(Request $request, Product $product): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        if (isset($data['name'])) $product->setName($data['name']);
        if (isset($data['productType'])) $product->setProductType($data['productType']);
        if (isset($data['price'])) $product->setPrice($data['price']);
        if (isset($data['stock'])) $product->setStock($data['stock']);
        if (isset($data['active'])) $product->setActive($data['active']);
        if (isset($data['discountPercent'])) $product->setDiscountPercent($data['discountPercent']);
        if (isset($data['description'])) $product->setDescription($data['description']);
        if (isset($data['imageUrl'])) $product->setImageUrl($data['imageUrl']);
        if (isset($data['featured'])) $product->setFeatured($data['featured']);
        if (array_key_exists('card', $data)) {
            $product->setCard($data['card'] !== null ? $this->cardRepository->find($data['card']) : null);
        }
        if (array_key_exists('cardSet', $data)) {
            $product->setCardSet($data['cardSet'] !== null ? $this->cardSetRepository->find($data['cardSet']) : null);
        }

        $errors = $this->validator->validate($product);
        if (count($errors) > 0) {
            return $this->json(['errors' => (string) $errors], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        $this->repository->save($product, flush: true);
        return $this->json($product, context: ['groups' => ['product:read']]);
    }

    #[Route('/{id}', name: 'delete', methods: ['DELETE'])]
    public function delete(Product $product): JsonResponse
    {
        $this->repository->remove($product, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/activate', name: 'activate', methods: ['POST'])]
    public function activate(Product $product): JsonResponse
    {
        $product->activate();
        $this->repository->save($product, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/deactivate', name: 'deactivate', methods: ['POST'])]
    public function deactivate(Product $product): JsonResponse
    {
        $product->deactivate();
        $this->repository->save($product, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/discount', name: 'applyDiscount', methods: ['PATCH'])]
    public function applyDiscount(Product $product, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $result = $product->applyDiscount($data['percent'] ?? null);
        $this->repository->save($product, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/restock', name: 'restock', methods: ['POST'])]
    public function restock(Product $product, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true) ?? [];
        $product->restock($data['quantity'] ?? null);
        $this->repository->save($product, flush: true);
        return $this->json(null, Response::HTTP_NO_CONTENT);
    }

    #[Route('/{id}/effective-price', name: 'effectivePrice', methods: ['GET'])]
    public function effectivePrice(Product $product): JsonResponse
    {
        $result = $product->effectivePrice();
        $this->repository->save($product, flush: true);
        return $this->json($result);
    }

    #[Route('/{id}/in-stock', name: 'isInStock', methods: ['GET'])]
    public function isInStock(Product $product): JsonResponse
    {
        $result = $product->isInStock();
        $this->repository->save($product, flush: true);
        return $this->json($result);
    }
}
