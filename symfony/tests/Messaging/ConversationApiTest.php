<?php

namespace App\Tests\Messaging;

use App\Entity\Messaging\Conversation;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;
use App\Entity\Messaging\Message;

class ConversationApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depPlayer1;
    private Player $depPlayer2;
    private Player $auxPlayer;
    private Message $depMessages;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->depPlayer1 = new Player();
        $this->depPlayer1->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depPlayer1);
        $this->depPlayer2 = new Player();
        $this->depPlayer2->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depPlayer2);
        $this->auxPlayer = new Player();
        $this->auxPlayer->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->auxPlayer);
        $this->depMessages = new Message();
        $this->depMessages->setSender($this->auxPlayer);
        $this->em->persist($this->depMessages);

        $entity = new Conversation();
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setPlayer1($this->depPlayer1);
        $entity->setPlayer2($this->depPlayer2);
        $entity->setMessages($this->depMessages);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/conversations');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/conversations', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'isArchivedByPlayer1' => true,
            'isArchivedByPlayer2' => true,
            'player1' => (int) $this->depPlayer1->getId(),
            'player2' => (int) $this->depPlayer2->getId(),
            'messages' => (int) $this->depMessages->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/conversations/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/conversations/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['createdAt' => '2024-01-01T00:00:00+00:00'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/conversations/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
