<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\TradeTransaction;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class TradeTransactionApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new TradeTransaction();
        $entity->setFinalPrice('0.00');
        $entity->setPlatformFee('0.00');
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/trade_transactions');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/trade_transactions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'final_price' => '0.00',
            'platform_fee' => '0.00',
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/trade_transactions/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/trade_transactions/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['final_price' => '0.00'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/trade_transactions/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
