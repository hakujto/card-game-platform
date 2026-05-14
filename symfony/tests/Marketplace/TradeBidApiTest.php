<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\TradeBid;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;
use App\Entity\Marketplace\Tradelisting;

class TradeBidApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $auxPlayer;
    private CardSet $auxCardSet;
    private Card $auxCard;
    private Tradelisting $depListing;
    private Player $depBidder;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxPlayer = new Player();
        $this->em->persist($this->auxPlayer);
        $this->auxCardSet = new CardSet();
        $this->em->persist($this->auxCardSet);
        $this->auxCard = new Card();
        $this->auxCard->setSet($this->auxCardSet);
        $this->em->persist($this->auxCard);
        $this->depListing = new Tradelisting();
        $this->depListing->setSeller($this->auxPlayer);
        $this->depListing->setCard($this->auxCard);
        $this->em->persist($this->depListing);
        $this->depBidder = new Player();
        $this->em->persist($this->depBidder);

        $entity = new TradeBid();
        $entity->setAmount('0.01');
        $entity->setPlacedAt(new \DateTime('2024-01-01'));
        $entity->setListing($this->depListing);
        $entity->setBidder($this->depBidder);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/trade_bids');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/trade_bids', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'amount' => '0.01',
            'placedAt' => '2024-01-01T00:00:00+00:00',
            'listing' => (int) $this->depListing->getId(),
            'bidder' => (int) $this->depBidder->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/trade_bids/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/trade_bids/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['amount' => '0.01'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/trade_bids/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenAmountPositiveViolated(): void
    {
        // Bid amount must be greater than zero
        $this->client->request('POST', '/api/trade_bids', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['placedAt' => '2024-01-01T00:00:00+00:00', 'isWinning' => true, 'amount' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
