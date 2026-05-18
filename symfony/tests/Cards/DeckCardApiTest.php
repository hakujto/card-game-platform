<?php

namespace App\Tests\Cards;

use App\Entity\Cards\DeckCard;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Cards\Deck;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;

class DeckCardApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $auxPlayer;
    private Deck $depDeck;
    private CardSet $auxCardSet;
    private Card $depCard;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxPlayer = new Player();
        $this->em->persist($this->auxPlayer);
        $this->depDeck = new Deck();
        $this->depDeck->setPlayer($this->auxPlayer);
        $this->em->persist($this->depDeck);
        $this->auxCardSet = new CardSet();
        $this->em->persist($this->auxCardSet);
        $this->depCard = new Card();
        $this->depCard->setSet($this->auxCardSet);
        $this->em->persist($this->depCard);

        $entity = new DeckCard();
        $entity->setDeck($this->depDeck);
        $entity->setCard($this->depCard);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/deck_cards');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/deck_cards', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'deck' => (int) $this->depDeck->getId(),
            'card' => (int) $this->depCard->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/deck_cards/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/deck_cards/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['quantity' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/deck_cards/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenQuantityRangeViolated(): void
    {
        // A deck can contain between 1 and 4 copies of a card
        $this->client->request('POST', '/api/deck_cards', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['isCommander' => true, 'deckId' => 1, 'cardId' => 1, 'quantity' => 5])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
