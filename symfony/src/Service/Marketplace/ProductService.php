<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\Product;
use App\Repository\Marketplace\ProductRepository;

class ProductService
{
    public function __construct(
        private ProductRepository $repository,
    ) {}

    public function create(array $data): Product
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Product $entity, array $data): Product
    {
        throw new \LogicException('Not implemented');
    }

    public function activate(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Product not found: ' . $id);
        $entity->activate();
        $this->repository->save($entity, flush: true);
    }

    public function deactivate(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Product not found: ' . $id);
        $entity->deactivate();
        $this->repository->save($entity, flush: true);
    }

    public function applyDiscount(int $id, $percent): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Product not found: ' . $id);
        $result = $entity->applyDiscount($percent);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function restock(int $id, $quantity): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Product not found: ' . $id);
        $entity->restock($quantity);
        $this->repository->save($entity, flush: true);
    }
}
