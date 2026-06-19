<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\TradeBid;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;
use App\Entity\Marketplace\TradeListing;

class TradeBidApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $auxPlayer;
    private CardSet $auxCardSet;
    private Card $auxCard;
    private TradeListing $depListing;
    private Player $depBidder;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxPlayer = new Player();
        $this->auxPlayer->setDisplayName('test2');
        $this->auxPlayer->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->auxPlayer);
        $this->auxCardSet = new CardSet();
        $this->auxCardSet->setName('test');
        $this->auxCardSet->setCode('test3');
        $this->auxCardSet->setReleaseDate(new \DateTime('2024-01-01'));
        $this->auxCardSet->setTotalCards(1);
        $this->em->persist($this->auxCardSet);
        $this->auxCard = new Card();
        $this->auxCard->setName('test');
        $this->auxCard->setManaColors('test');
        $this->auxCard->setDescription('test');
        $this->auxCard->setLegalFormats('test');
        $this->auxCard->setSet($this->auxCardSet);
        $this->em->persist($this->auxCard);
        $this->depListing = new TradeListing();
        $this->depListing->setCreatedAt(new \DateTime('2024-01-01'));
        $this->depListing->setSeller($this->auxPlayer);
        $this->depListing->setCard($this->auxCard);
        $this->em->persist($this->depListing);
        $this->depBidder = new Player();
        $this->depBidder->setDisplayName('test6');
        $this->depBidder->setCreatedAt(new \DateTime('2024-01-01'));
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

    public function testCreateFailsWhenAmountPositiveViolated(): void
    {
        // Bid amount must be greater than zero
        $this->client->request('POST', '/api/trade_bids', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['placedAt' => '2024-01-01T00:00:00+00:00', 'isWinning' => true, 'listingId' => 1, 'bidderId' => 1, 'amount' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
