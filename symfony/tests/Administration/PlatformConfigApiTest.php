<?php

namespace App\Tests\Administration;

use App\Entity\Administration\PlatformConfig;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class PlatformConfigApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depUpdatedBy;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->depUpdatedBy = new Player();
        $this->depUpdatedBy->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depUpdatedBy);

        $entity = new PlatformConfig();
        $entity->setConfigKey('test');
        $entity->setConfigValue('test');
        $entity->setUpdatedAt(new \DateTime('2024-01-01'));
        $entity->setUpdatedBy($this->depUpdatedBy);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/platform_configs');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/platform_configs', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'configKey' => 'test',
            'configValue' => 'test',
            'updatedAt' => '2024-01-01T00:00:00+00:00',
            'updatedBy' => (int) $this->depUpdatedBy->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/platform_configs/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/platform_configs/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['configKey' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/platform_configs/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
