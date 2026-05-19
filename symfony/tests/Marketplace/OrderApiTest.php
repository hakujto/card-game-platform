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
            json_encode(['total' => '0.00', 'discountApplied' => '0.00', 'currency' => 'test', 'createdAt' => '2024-01-01T00:00:00+00:00', 'playerId' => 1, 'status' => 'PAID', 'paidAt' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenShippedRequiresTrackingViolated(): void
    {
        // Shipped order must have a tracking number
        $this->client->request('POST', '/api/orders', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['total' => '0.00', 'discountApplied' => '0.00', 'currency' => 'test', 'createdAt' => '2024-01-01T00:00:00+00:00', 'playerId' => 1, 'status' => 'SHIPPED', 'trackingNumber' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenShippedAtRequiresShippedStatusViolated(): void
    {
        // shipped_at_requires_shipped_status
        $this->client->request('POST', '/api/orders', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'PENDING', 'total' => '0.00', 'discountApplied' => '0.00', 'currency' => 'test', 'createdAt' => '2024-01-01T00:00:00+00:00', 'playerId' => 1, 'shippedAt' => '2024-01-01T00:00:00+00:00'])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenTotalNotNegativeViolated(): void
    {
        // Order total must not be negative
        $this->client->request('POST', '/api/orders', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['discountApplied' => '0.00', 'currency' => 'test', 'createdAt' => '2024-01-01T00:00:00+00:00', 'playerId' => 1, 'status' => 'PAID', 'paidAt' => '2024-01-01T00:00:00+00:00', 'status' => 'SHIPPED', 'trackingNumber' => 'test', 'shippedAt' => '2024-01-01T00:00:00+00:00', 'status' => 'SHIPPED', 'total' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }
    public function testTransitionPendingToPaidSucceeds(): void
    {
        // Arrange: set entity to 'Pending' state
        $entity = $this->em->find(Order::class, $this->entityId);
        $entity->setStatus('Pending');
        $entity->setPaymentMethod('test'); // @on: payment_method != null
        $this->em->flush();

        $this->client->request('PATCH', '/api/orders/' . $this->entityId . '/transitions/pending-to-paid');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Paid', $data['status'] ?? null);
    }

    public function testTransitionPendingToPaidFailsWhenPaymentMethodMissing(): void
    {
        // Arrange: entity in 'Pending' state without payment_method
        $entity = $this->em->find(Order::class, $this->entityId);
        $entity->setStatus('Pending');
        $this->em->flush();

        $this->client->request('PATCH', '/api/orders/' . $this->entityId . '/transitions/pending-to-paid');
        $this->assertResponseStatusCodeSame(422);
    }

    public function testTransitionPaidToProcessingSucceeds(): void
    {
        // Arrange: set entity to 'Paid' state
        $entity = $this->em->find(Order::class, $this->entityId);
        $entity->setStatus('Paid');
        $this->em->flush();

        $this->client->request('PATCH', '/api/orders/' . $this->entityId . '/transitions/paid-to-processing');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Processing', $data['status'] ?? null);
    }

    public function testTransitionProcessingToShippedSucceeds(): void
    {
        // Arrange: set entity to 'Processing' state
        $entity = $this->em->find(Order::class, $this->entityId);
        $entity->setStatus('Processing');
        $entity->setTrackingNumber('test'); // @on: tracking_number != null
        $this->em->flush();

        $this->client->request('PATCH', '/api/orders/' . $this->entityId . '/transitions/processing-to-shipped');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Shipped', $data['status'] ?? null);
    }

    public function testTransitionProcessingToShippedFailsWhenTrackingNumberMissing(): void
    {
        // Arrange: entity in 'Processing' state without tracking_number
        $entity = $this->em->find(Order::class, $this->entityId);
        $entity->setStatus('Processing');
        $this->em->flush();

        $this->client->request('PATCH', '/api/orders/' . $this->entityId . '/transitions/processing-to-shipped');
        $this->assertResponseStatusCodeSame(422);
    }

    public function testTransitionShippedToCompletedSucceeds(): void
    {
        // Arrange: set entity to 'Shipped' state
        $entity = $this->em->find(Order::class, $this->entityId);
        $entity->setStatus('Shipped');
        $this->em->flush();

        $this->client->request('PATCH', '/api/orders/' . $this->entityId . '/transitions/shipped-to-completed');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Completed', $data['status'] ?? null);
    }

    public function testTransitionPendingToCancelledSucceeds(): void
    {
        // Arrange: set entity to 'Pending' state
        $entity = $this->em->find(Order::class, $this->entityId);
        $entity->setStatus('Pending');
        $this->em->flush();

        $this->client->request('PATCH', '/api/orders/' . $this->entityId . '/transitions/pending-to-cancelled');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Cancelled', $data['status'] ?? null);
    }

    public function testTransitionPaidToCancelledSucceeds(): void
    {
        // Arrange: set entity to 'Paid' state
        $entity = $this->em->find(Order::class, $this->entityId);
        $entity->setStatus('Paid');
        $this->em->flush();

        $this->client->request('PATCH', '/api/orders/' . $this->entityId . '/transitions/paid-to-cancelled');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Cancelled', $data['status'] ?? null);
    }

    public function testTransitionCompletedToRefundedSucceeds(): void
    {
        // Arrange: set entity to 'Completed' state
        $entity = $this->em->find(Order::class, $this->entityId);
        $entity->setStatus('Completed');
        $this->em->flush();

        $this->client->request('PATCH', '/api/orders/' . $this->entityId . '/transitions/completed-to-refunded');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Refunded', $data['status'] ?? null);
    }

    public function testTransitionRefundedToCompletedIsDenied(): void
    {
        // Arrange: entity exists (any state)
        $this->client->request('PATCH', '/api/orders/' . $this->entityId . '/transitions/refunded-to-completed');
        $this->assertResponseStatusCodeSame(409);
    }

    public function testTransitionCompletedToCancelledIsDenied(): void
    {
        // Arrange: entity exists (any state)
        $this->client->request('PATCH', '/api/orders/' . $this->entityId . '/transitions/completed-to-cancelled');
        $this->assertResponseStatusCodeSame(409);
    }
}
