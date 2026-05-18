<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\TradeTransaction;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;
use App\Entity\Marketplace\TradeListing;

class TradeTransactionApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $auxPlayer;
    private CardSet $auxCardSet;
    private Card $auxCard;
    private TradeListing $depListing;
    private Player $depBuyer;
    private Player $depSeller;

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
        $this->depListing = new TradeListing();
        $this->depListing->setSeller($this->auxPlayer);
        $this->depListing->setCard($this->auxCard);
        $this->em->persist($this->depListing);
        $this->depBuyer = new Player();
        $this->em->persist($this->depBuyer);
        $this->depSeller = new Player();
        $this->em->persist($this->depSeller);

        $entity = new TradeTransaction();
        $entity->setFinalPrice('0.01');
        $entity->setPlatformFee('NaN');
        $entity->setListing($this->depListing);
        $entity->setBuyer($this->depBuyer);
        $entity->setSeller($this->depSeller);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/trade_transactions');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $freshListing = new TradeListing();
        $freshListing->setSeller($this->auxPlayer);
        $freshListing->setCard($this->auxCard);
        $this->em->persist($freshListing);
        $this->em->flush();
        $this->client->request('POST', '/api/trade_transactions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'finalPrice' => '0.01',
            'platformFee' => 'NaN',
            'listing' => (int) $freshListing->getId(),
            'buyer' => (int) $this->depBuyer->getId(),
            'seller' => (int) $this->depSeller->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/trade_transactions/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/trade_transactions/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['finalPrice' => '0.01'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/trade_transactions/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenFeeNotNegativeViolated(): void
    {
        // Platform fee must not be negative
        $this->client->request('POST', '/api/trade_transactions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['finalPrice' => '0.00', 'listingId' => 1, 'buyerId' => 1, 'sellerId' => 1, 'status' => 'COMPLETED', 'completedAt' => '2024-01-01T00:00:00+00:00', 'platformFee' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenFinalPricePositiveViolated(): void
    {
        // Transaction final price must be greater than zero
        $this->client->request('POST', '/api/trade_transactions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['platformFee' => '0.00', 'listingId' => 1, 'buyerId' => 1, 'sellerId' => 1, 'status' => 'COMPLETED', 'completedAt' => '2024-01-01T00:00:00+00:00', 'finalPrice' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenCompletedRequiresCompletedAtViolated(): void
    {
        // Completed transaction must have a completed_at timestamp
        $this->client->request('POST', '/api/trade_transactions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['finalPrice' => '0.00', 'platformFee' => '0.00', 'listingId' => 1, 'buyerId' => 1, 'sellerId' => 1, 'status' => 'COMPLETED', 'completedAt' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
