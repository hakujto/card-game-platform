<?php

namespace App\Tests\Leaderboard;

use App\Entity\Leaderboard\LeaderboardEntry;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class LeaderboardEntryApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depPlayer;
    private Season $depSeason;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->depPlayer = new Player();
        $this->depPlayer->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depPlayer);
        $this->depSeason = new Season();
        $this->em->persist($this->depSeason);

        $entity = new LeaderboardEntry();
        $entity->setPosition(1);
        $entity->setRating(1);
        $entity->setUpdatedAt(new \DateTime('2024-01-01'));
        $entity->setPlayer($this->depPlayer);
        $entity->setSeason($this->depSeason);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/leaderboard_entries');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/leaderboard_entries', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'position' => 1,
            'rating' => 1,
            'wins' => 1,
            'losses' => 1,
            'winRate' => '0.00',
            'tournamentWins' => 1,
            'seasonPoints' => 1,
            'updatedAt' => '2024-01-01T00:00:00+00:00',
            'player' => (int) $this->depPlayer->getId(),
            'season' => (int) $this->depSeason->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/leaderboard_entries/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/leaderboard_entries/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['position' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/leaderboard_entries/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
