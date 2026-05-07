<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\CardPriceHistory;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class CardPriceHistoryApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new CardPriceHistory();
        $entity->setPriceDate(new \DateTime('2024-01-01'));
        $entity->setAvgPrice('0.00');
        $entity->setMinPrice('0.00');
        $entity->setMaxPrice('0.00');
        $entity->setVolume(1);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/card_price_histories');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/card_price_histories', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'price_date' => new \DateTime('2024-01-01'),
            'avg_price' => '0.00',
            'min_price' => '0.00',
            'max_price' => '0.00',
            'volume' => 1,
            'foil' => true,
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/card_price_histories/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/card_price_histories/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['price_date' => new \DateTime('2024-01-01')])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/card_price_histories/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
