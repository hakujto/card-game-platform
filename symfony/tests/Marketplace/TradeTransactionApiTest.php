<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\TradeTransaction;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;
use App\Entity\Marketplace\Tradelisting;

class TradeTransactionApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $auxPlayer;
    private CardSet $auxCardSet;
    private Card $auxCard;
    private Tradelisting $depListing;
    private Player $depBuyer;
    private Player $depSeller;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->auxPlayer = new Player();
        $this->auxPlayer->setSeasonStats($this->auxPlayerSeasonStats);
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
        $this->depBuyer = new Player();
        $this->depBuyer->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depBuyer);
        $this->depSeller = new Player();
        $this->depSeller->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depSeller);

        $entity = new TradeTransaction();
        $entity->setFinalPrice('0.00');
        $entity->setPlatformFee('0.00');
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
        $freshListing = new Tradelisting();
        $freshListing->setSeller($this->auxPlayer);
        $freshListing->setCard($this->auxCard);
        $this->em->persist($freshListing);
        $this->em->flush();
        $this->client->request('POST', '/api/trade_transactions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'finalPrice' => '0.00',
            'platformFee' => '0.00',
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
            json_encode(['finalPrice' => '0.00'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/trade_transactions/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
