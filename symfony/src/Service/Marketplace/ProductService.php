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
}
