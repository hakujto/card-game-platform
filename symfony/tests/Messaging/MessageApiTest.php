<?php

namespace App\Tests\Messaging;

use App\Entity\Messaging\Message;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class MessageApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depSender;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->depSender = new Player();
        $this->depSender->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depSender);

        $entity = new Message();
        $entity->setBody('test');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setSender($this->depSender);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/messages');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/messages', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'body' => 'test',
            'isRead' => true,
            'isDeletedBySender' => true,
            'isDeletedByReceiver' => true,
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'sender' => (int) $this->depSender->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/messages/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/messages/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['body' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/messages/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
