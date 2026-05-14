<?php

namespace App\Tests\Players;

use App\Entity\Players\PlayerCollection;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;

class PlayerCollectionApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $depPlayer;
    private CardSet $auxCardSet;
    private Card $depCard;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depPlayer = new Player();
        $this->em->persist($this->depPlayer);
        $this->auxCardSet = new CardSet();
        $this->em->persist($this->auxCardSet);
        $this->depCard = new Card();
        $this->depCard->setSet($this->auxCardSet);
        $this->em->persist($this->depCard);

        $entity = new PlayerCollection();
        $entity->setAcquiredAt(new \DateTime('2024-01-01'));
        $entity->setPlayer($this->depPlayer);
        $entity->setCard($this->depCard);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/player_collections');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/player_collections', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'acquiredAt' => '2024-01-01T00:00:00+00:00',
            'player' => (int) $this->depPlayer->getId(),
            'card' => (int) $this->depCard->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/player_collections/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/player_collections/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['quantity' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/player_collections/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

}
