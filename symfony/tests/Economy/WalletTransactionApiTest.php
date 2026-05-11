<?php

namespace App\Tests\Economy;

use App\Entity\Economy\WalletTransaction;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;
use App\Entity\Economy\Wallet;

class WalletTransactionApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $auxPlayer;
    private Wallet $depWallet;

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
        $this->depWallet = new Wallet();
        $this->depWallet->setPlayer($this->auxPlayer);
        $this->em->persist($this->depWallet);

        $entity = new WalletTransaction();
        $entity->setTransactionType('test');
        $entity->setCurrency('test');
        $entity->setAmount('0.00');
        $entity->setBalanceAfter('0.00');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setWallet($this->depWallet);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/wallet_transactions');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/wallet_transactions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'amount' => '0.00',
            'balanceAfter' => '0.00',
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'wallet' => (int) $this->depWallet->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/wallet_transactions/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/wallet_transactions/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['transactionType' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/wallet_transactions/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
