<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\TradeListing;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;

class TradeListingApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $depSeller;
    private CardSet $auxCardSet;
    private Card $depCard;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depSeller = new Player();
        $this->em->persist($this->depSeller);
        $this->auxCardSet = new CardSet();
        $this->em->persist($this->auxCardSet);
        $this->depCard = new Card();
        $this->depCard->setSet($this->auxCardSet);
        $this->em->persist($this->depCard);

        $entity = new TradeListing();
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setSeller($this->depSeller);
        $entity->setCard($this->depCard);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/trade_listings');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/trade_listings', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'seller' => (int) $this->depSeller->getId(),
            'card' => (int) $this->depCard->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/trade_listings/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/trade_listings/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['listingType' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/trade_listings/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenFixedPriceRequiresAskingPriceViolated(): void
    {
        // Fixed price listing must have an asking price
        $this->client->request('POST', '/api/trade_listings', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['foil' => true, 'condition' => 'MINT', 'quantity' => 1, 'status' => 'ACTIVE', 'createdAt' => '2024-01-01T00:00:00+00:00', 'sellerId' => 1, 'cardId' => 1, 'listingType' => 'FIXEDPRICE', 'askingPrice' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenAuctionRequiresStartPriceAndEndTimeViolated(): void
    {
        // Auction listing must have a start price and end time
        $this->client->request('POST', '/api/trade_listings', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['foil' => true, 'condition' => 'MINT', 'quantity' => 1, 'status' => 'ACTIVE', 'createdAt' => '2024-01-01T00:00:00+00:00', 'sellerId' => 1, 'cardId' => 1, 'listingType' => 'AUCTION', 'auctionStartPrice' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenQuantityPositiveViolated(): void
    {
        // Listing quantity must be between 1 and 9999
        $this->client->request('POST', '/api/trade_listings', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['foil' => true, 'condition' => 'MINT', 'status' => 'ACTIVE', 'createdAt' => '2024-01-01T00:00:00+00:00', 'sellerId' => 1, 'cardId' => 1, 'listingType' => 'FIXEDPRICE', 'askingPrice' => '0.00', 'listingType' => 'AUCTION', 'auctionStartPrice' => '0.00', 'auctionEndTime' => '2024-01-01T00:00:00+00:00', 'quantity' => 10000])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
