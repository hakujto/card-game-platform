<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\TradeDispute;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;
use App\Entity\Marketplace\TradeListing;
use App\Entity\Marketplace\TradeTransaction;

class TradeDisputeApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $auxPlayer;
    private CardSet $auxCardSet;
    private Card $auxCard;
    private TradeListing $auxTradeListing;
    private TradeTransaction $depTransaction;
    private Player $depOpenedBy;

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
        $this->auxTradeListing = new TradeListing();
        $this->auxTradeListing->setSeller($this->auxPlayer);
        $this->auxTradeListing->setCard($this->auxCard);
        $this->em->persist($this->auxTradeListing);
        $this->depTransaction = new TradeTransaction();
        $this->depTransaction->setListing($this->auxTradeListing);
        $this->depTransaction->setBuyer($this->auxPlayer);
        $this->depTransaction->setSeller($this->auxPlayer);
        $this->em->persist($this->depTransaction);
        $this->depOpenedBy = new Player();
        $this->em->persist($this->depOpenedBy);

        $entity = new TradeDispute();
        $entity->setReason('test');
        $entity->setDescription('test');
        $entity->setOpenedAt(new \DateTime('2024-01-01'));
        $entity->setTransaction($this->depTransaction);
        $entity->setOpenedBy($this->depOpenedBy);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/trade_disputes');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $freshSubListing = new TradeListing();
        $freshSubListing->setSeller($this->auxPlayer);
        $freshSubListing->setCard($this->auxCard);
        $this->em->persist($freshSubListing);
        $freshTransaction = new TradeTransaction();
        $freshTransaction->setListing($freshSubListing);
        $freshTransaction->setBuyer($this->auxPlayer);
        $freshTransaction->setSeller($this->auxPlayer);
        $this->em->persist($freshTransaction);
        $this->em->flush();
        $this->client->request('POST', '/api/trade_disputes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'description' => 'test',
            'openedAt' => '2024-01-01T00:00:00+00:00',
            'transaction' => (int) $freshTransaction->getId(),
            'openedBy' => (int) $this->depOpenedBy->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/trade_disputes/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/trade_disputes/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['reason' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/trade_disputes/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenResolvedAtRequiresTerminalStatusViolated(): void
    {
        // resolved_at_requires_terminal_status
        $this->client->request('POST', '/api/trade_disputes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['reason' => 'ITEMNOTRECEIVED', 'description' => 'test', 'status' => 'OPEN', 'openedAt' => '2024-01-01T00:00:00+00:00', 'transactionId' => 1, 'openedById' => 1, 'resolvedAt' => '2024-01-01T00:00:00+00:00'])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
