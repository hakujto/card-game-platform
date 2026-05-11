<?php

namespace App\Tests\Players;

use App\Entity\Players\Player;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;

class PlayerApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $depSeasonStats;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->depSeasonStats = new PlayerSeasonStats();
        $this->depSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->depSeasonStats);

        $entity = new Player();
        $entity->setDisplayName('test');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setSeasonStats($this->depSeasonStats);
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
            'seasonStats' => (int) $this->depSeasonStats->getId(),
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
}
