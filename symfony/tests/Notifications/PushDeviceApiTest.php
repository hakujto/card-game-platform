<?php

namespace App\Tests\Notifications;

use App\Entity\Notifications\PushDevice;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class PushDeviceApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depPlayer;

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

        $entity = new PushDevice();
        $entity->setDeviceToken('test');
        $entity->setRegisteredAt(new \DateTime('2024-01-01'));
        $entity->setPlayer($this->depPlayer);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/push_devices');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/push_devices', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'deviceToken' => 'test',
            'isActive' => true,
            'registeredAt' => '2024-01-01T00:00:00+00:00',
            'player' => (int) $this->depPlayer->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/push_devices/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/push_devices/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['deviceToken' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/push_devices/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
