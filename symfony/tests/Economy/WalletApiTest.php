<?php

namespace App\Tests\Economy;

use App\Entity\Economy\Wallet;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class WalletApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depPlayer;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->depPlayer = new Player();
        $this->depPlayer->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depPlayer);

        $entity = new Wallet();
        $entity->setUpdatedAt(new \DateTime('2024-01-01'));
        $entity->setPlayer($this->depPlayer);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/wallets');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $freshPlayer = new Player();
        $freshPlayer->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($freshPlayer);
        $this->em->flush();
        $this->client->request('POST', '/api/wallets', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'creditsBalance' => '0.00',
            'dustBalance' => 1,
            'gemsBalance' => 1,
            'updatedAt' => '2024-01-01T00:00:00+00:00',
            'player' => (int) $freshPlayer->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/wallets/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/wallets/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['creditsBalance' => '0.00'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/wallets/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
