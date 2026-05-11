<?php

namespace App\Tests\Moderation;

use App\Entity\Moderation\ContentReport;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class ContentReportApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
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
        $this->depReporter = new Player();
        $this->depReporter->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depReporter);

        $entity = new ContentReport();
        $entity->setTargetType('test');
        $entity->setReason('test');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setReporter($this->depReporter);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/content_reports');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/content_reports', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'reporter' => (int) $this->depReporter->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/content_reports/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/content_reports/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['targetType' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/content_reports/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
