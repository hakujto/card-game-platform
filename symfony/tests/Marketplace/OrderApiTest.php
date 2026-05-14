<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\Order;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;

class OrderApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $depPlayer;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depPlayer = new Player();
        $this->em->persist($this->depPlayer);

        $entity = new Order();
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setPlayer($this->depPlayer);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/orders');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/orders', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'player' => (int) $this->depPlayer->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/orders/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/orders/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/orders/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenPaidRequiresPaidAtViolated(): void
    {
        // Paid order must have paid_at set
        $this->client->request('POST', '/api/orders', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['total' => '0.00', 'discountApplied' => '0.00', 'currency' => 'test', 'createdAt' => '2024-01-01T00:00:00+00:00', 'status' => 'PAID', 'paidAt' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenShippedRequiresTrackingViolated(): void
    {
        // Shipped order must have a tracking number
        $this->client->request('POST', '/api/orders', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['total' => '0.00', 'discountApplied' => '0.00', 'currency' => 'test', 'createdAt' => '2024-01-01T00:00:00+00:00', 'status' => 'SHIPPED', 'trackingNumber' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenTotalNotNegativeViolated(): void
    {
        // Order total must not be negative
        $this->client->request('POST', '/api/orders', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['discountApplied' => '0.00', 'currency' => 'test', 'createdAt' => '2024-01-01T00:00:00+00:00', 'status' => 'PAID', 'paidAt' => '2024-01-01T00:00:00+00:00', 'status' => 'SHIPPED', 'trackingNumber' => 'test', 'total' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
