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
        $this->depBuyer = new Player();
        $this->depBuyer->setDisplayName('test6');
        $this->depBuyer->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->depBuyer);
        $this->depSeller = new Player();
        $this->depSeller->setDisplayName('test7');
        $this->depSeller->setCreatedAt(new \DateTime('2024-01-01'));
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

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/trade_transactions/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

}
