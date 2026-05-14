<?php

namespace App\Tests\Players;

use App\Entity\Players\Player;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class PlayerApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new Player();
        $entity->setDisplayName('test');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/players');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/players', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'displayName' => 'test',
            'rating' => 1,
            'peakRating' => 1,
            'isVerified' => true,
            'createdAt' => '2024-01-01T00:00:00+00:00',
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/players/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/players/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['displayName' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/players/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenRatingRangeViolated(): void
    {
        // Rating must be between 0 and 9999
        $this->client->request('POST', '/api/players', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['displayName' => 'test', 'rank' => 'BRONZE', 'peakRating' => 1, 'isVerified' => true, 'createdAt' => '2024-01-01T00:00:00+00:00', 'rating' => 10000])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenPeakRatingGteRatingViolated(): void
    {
        // Peak rating must be greater than or equal to current rating
        $this->client->request('POST', '/api/players', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['displayName' => 'test', 'rank' => 'BRONZE', 'rating' => 1, 'isVerified' => true, 'createdAt' => '2024-01-01T00:00:00+00:00', 'peakRating' => NaN])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenDisplayNameNotEmptyViolated(): void
    {
        // Display name must not be empty
        $this->client->request('POST', '/api/players', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['rank' => 'BRONZE', 'rating' => 1, 'peakRating' => 1, 'isVerified' => true, 'createdAt' => '2024-01-01T00:00:00+00:00', 'displayName' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
