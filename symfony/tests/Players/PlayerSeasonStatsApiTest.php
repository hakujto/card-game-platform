<?php

namespace App\Tests\Players;

use App\Entity\Players\PlayerSeasonStats;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;

class PlayerSeasonStatsApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $depSeason;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depSeason = new Season();
        $this->em->persist($this->depSeason);

        $entity = new PlayerSeasonStats();
        $entity->setSeason($this->depSeason);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/player_season_statses');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/player_season_statses', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'season' => (int) $this->depSeason->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/player_season_statses/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/player_season_statses/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['wins' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/player_season_statses/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenWinsNotNegativeViolated(): void
    {
        // Season wins must not be negative
        $this->client->request('POST', '/api/player_season_statses', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['losses' => 1, 'draws' => 1, 'tournamentWins' => 1, 'seasonPoints' => 1, 'playerId' => 1, 'seasonId' => 1, 'wins' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenLossesNotNegativeViolated(): void
    {
        // Season losses must not be negative
        $this->client->request('POST', '/api/player_season_statses', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['wins' => 1, 'draws' => 1, 'tournamentWins' => 1, 'seasonPoints' => 1, 'playerId' => 1, 'seasonId' => 1, 'losses' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenTournamentWinsNotNegativeViolated(): void
    {
        // Season tournament wins must not be negative
        $this->client->request('POST', '/api/player_season_statses', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['wins' => 1, 'losses' => 1, 'draws' => 1, 'seasonPoints' => 1, 'playerId' => 1, 'seasonId' => 1, 'tournamentWins' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenSeasonPointsNotNegativeViolated(): void
    {
        // Season points must not be negative
        $this->client->request('POST', '/api/player_season_statses', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['wins' => 1, 'losses' => 1, 'draws' => 1, 'tournamentWins' => 1, 'playerId' => 1, 'seasonId' => 1, 'seasonPoints' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
