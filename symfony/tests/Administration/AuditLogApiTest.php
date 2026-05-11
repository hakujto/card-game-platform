<?php

namespace App\Tests\Administration;

use App\Entity\Administration\AuditLog;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class AuditLogApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depAdmin;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->depAdmin = new Player();
        $this->depAdmin->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depAdmin);

        $entity = new AuditLog();
        $entity->setAction('test');
        $entity->setTargetType('test');
        $entity->setTargetId('test');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setAdmin($this->depAdmin);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/audit_logs');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/audit_logs', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'action' => 'test',
            'targetType' => 'test',
            'targetId' => 'test',
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'admin' => (int) $this->depAdmin->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/audit_logs/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/audit_logs/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['action' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/audit_logs/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
