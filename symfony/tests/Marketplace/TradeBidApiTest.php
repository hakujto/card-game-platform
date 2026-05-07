<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\TradeBid;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class TradeBidApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new TradeBid();
        $entity->setAmount('0.00');
        $entity->setPlacedAt(new \DateTime('2024-01-01'));
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/trade_bids');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/trade_bids', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'amount' => '0.00',
            'placed_at' => new \DateTime('2024-01-01'),
            'is_winning' => true,
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/trade_bids/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/trade_bids/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['amount' => '0.00'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/trade_bids/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
