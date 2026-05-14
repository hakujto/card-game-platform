<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\OrderItem;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Marketplace\Product;

class OrderItemApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Product $depProduct;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depProduct = new Product();
        $this->em->persist($this->depProduct);

        $entity = new OrderItem();
        $entity->setQuantity(1);
        $entity->setPriceAtPurchase('0.00');
        $entity->setProduct($this->depProduct);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/order_items');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/order_items', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'quantity' => 1,
            'priceAtPurchase' => '0.00',
            'foil' => true,
            'product' => (int) $this->depProduct->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/order_items/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/order_items/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['quantity' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/order_items/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

}
