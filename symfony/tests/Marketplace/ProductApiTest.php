<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\Product;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class ProductApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new Product();
        $entity->setName('test');
        $entity->setPrice('0.01');
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/products');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/products', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'name' => 'test',
            'price' => '0.01',
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/products/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/products/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/products/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenPricePositiveViolated(): void
    {
        // Product price must be greater than zero
        $this->client->request('POST', '/api/products', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'productType' => 'SINGLECARD', 'stock' => 1, 'active' => true, 'discountPercent' => 1, 'featured' => true, 'price' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenStockNotNegativeViolated(): void
    {
        // Product stock must not be negative
        $this->client->request('POST', '/api/products', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'productType' => 'SINGLECARD', 'price' => '0.00', 'active' => true, 'discountPercent' => 1, 'featured' => true, 'stock' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenDiscountPercentRangeViolated(): void
    {
        // Product discount percent must be between 0 and 100
        $this->client->request('POST', '/api/products', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'productType' => 'SINGLECARD', 'price' => '0.00', 'stock' => 1, 'active' => true, 'featured' => true, 'discountPercent' => 101])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
