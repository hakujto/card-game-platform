<?php

namespace App\Tests\Players;

use App\Entity\Players\PlayerCollection;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;
use App\Entity\User;
use App\Entity\Players\Player;

class PlayerCollectionApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private User $ownerUser;
    private Player $ownerModel;
    private CardSet $auxCardSet;
    private Card $depCard;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->ownerUser = new User();
        $this->ownerUser->setEmail('owner@example.com');
        $this->ownerUser->setPassword('test');
        $this->em->persist($this->ownerUser);
        $this->ownerModel = new Player();
        $this->ownerModel->setUser($this->ownerUser);
        $this->ownerModel->setDisplayName('test1');
        $this->ownerModel->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->ownerModel);
        $this->em->flush();
        $this->client->loginUser($this->ownerUser);

        $this->auxCardSet = new CardSet();
        $this->auxCardSet->setName('test');
        $this->auxCardSet->setCode('test2');
        $this->auxCardSet->setReleaseDate(new \DateTime('2024-01-01'));
        $this->auxCardSet->setTotalCards(1);
        $this->em->persist($this->auxCardSet);
        $this->depCard = new Card();
        $this->depCard->setName('test');
        $this->depCard->setManaColors('test');
        $this->depCard->setDescription('test');
        $this->depCard->setLegalFormats('test');
        $this->depCard->setSet($this->auxCardSet);
        $this->em->persist($this->depCard);

        $entity = new PlayerCollection();
        $entity->setAcquiredAt(new \DateTime('2024-01-01'));
        $entity->setCard($this->depCard);
        $entity->setPlayer($this->ownerModel);
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
            'card' => (int) $this->depCard->getId(),
            'player' => (int) $this->ownerModel->getId(),
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

    public function testCreateFailsWhenQuantityPositiveViolated(): void
    {
        // Collection quantity must be greater than zero
        $this->client->request('POST', '/api/player_collections', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['foil' => true, 'condition' => 'MINT', 'acquiredAt' => '2024-01-01T00:00:00+00:00', 'acquiredVia' => 'PURCHASE', 'playerId' => 1, 'cardId' => 1, 'quantity' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
