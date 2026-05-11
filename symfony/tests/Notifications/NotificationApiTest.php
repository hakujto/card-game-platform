<?php

namespace App\Tests\Notifications;

use App\Entity\Notifications\Notification;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class NotificationApiTest extends WebTestCase
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

        $entity = new Notification();
        $entity->setNotificationType('test');
        $entity->setTitle('test');
        $entity->setBody('test');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setPlayer($this->depPlayer);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/notifications');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/notifications', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'title' => 'test',
            'body' => 'test',
            'isRead' => true,
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'player' => (int) $this->depPlayer->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/notifications/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/notifications/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['notificationType' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/notifications/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
