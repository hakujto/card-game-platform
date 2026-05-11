<?php

namespace App\Tests\Moderation;

use App\Entity\Moderation\PlayerReport;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class PlayerReportApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depReportedPlayer;
    private Player $depReporter;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->depReportedPlayer = new Player();
        $this->depReportedPlayer->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depReportedPlayer);
        $this->depReporter = new Player();
        $this->depReporter->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depReporter);

        $entity = new PlayerReport();
        $entity->setReason('test');
        $entity->setDescription('test');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setReportedPlayer($this->depReportedPlayer);
        $entity->setReporter($this->depReporter);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/player_reports');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/player_reports', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'description' => 'test',
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'reportedPlayer' => (int) $this->depReportedPlayer->getId(),
            'reporter' => (int) $this->depReporter->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/player_reports/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/player_reports/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['reason' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/player_reports/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
