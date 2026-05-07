<?php

namespace App\Tests\Players;

use App\Entity\Players\PlayerSeasonStats;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class PlayerSeasonStatsApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new PlayerSeasonStats();

        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/player_season_statses');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/player_season_statses', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'wins' => 1,
            'losses' => 1,
            'draws' => 1,
            'tournament_wins' => 1,
            'season_points' => 1,
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/player_season_statses/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/player_season_statses/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['wins' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/player_season_statses/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
