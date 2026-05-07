<?php

namespace App\Tests\Players;

use App\Entity\Players\PlayerCollection;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class PlayerCollectionApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new PlayerCollection();
        $entity->setAcquiredAt(new \DateTime('2024-01-01'));
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/player_collections');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/player_collections', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'quantity' => 1,
            'foil' => true,
            'acquired_at' => new \DateTime('2024-01-01'),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/player_collections/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/player_collections/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['quantity' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/player_collections/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
