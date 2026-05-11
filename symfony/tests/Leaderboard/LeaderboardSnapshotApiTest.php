<?php

namespace App\Tests\Leaderboard;

use App\Entity\Leaderboard\LeaderboardSnapshot;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;
use App\Entity\Leaderboard\LeaderboardEntry;

class LeaderboardSnapshotApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $auxPlayer;
    private LeaderboardEntry $depEntry;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->auxPlayer = new Player();
        $this->auxPlayer->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->auxPlayer);
        $this->depEntry = new LeaderboardEntry();
        $this->depEntry->setPlayer($this->auxPlayer);
        $this->depEntry->setSeason($this->auxSeason);
        $this->em->persist($this->depEntry);

        $entity = new LeaderboardSnapshot();
        $entity->setSnapshotDate(new \DateTime('2024-01-01'));
        $entity->setPosition(1);
        $entity->setRating(1);
        $entity->setEntry($this->depEntry);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/leaderboard_snapshots');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/leaderboard_snapshots', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'snapshotDate' => '2024-01-01',
            'position' => 1,
            'rating' => 1,
            'seasonPoints' => 1,
            'entry' => (int) $this->depEntry->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/leaderboard_snapshots/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/leaderboard_snapshots/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['snapshotDate' => '2024-01-01'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/leaderboard_snapshots/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
