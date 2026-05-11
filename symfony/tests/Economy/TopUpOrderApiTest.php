<?php

namespace App\Tests\Economy;

use App\Entity\Economy\TopUpOrder;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class TopUpOrderApiTest extends WebTestCase
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

        $entity = new TopUpOrder();
        $entity->setAmountPaid('0.00');
        $entity->setCreditsGranted('0.00');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setPlayer($this->depPlayer);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/top_up_orders');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/top_up_orders', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'amountPaid' => '0.00',
            'currencyPaid' => 'test',
            'creditsGranted' => '0.00',
            'gemsGranted' => 1,
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'player' => (int) $this->depPlayer->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/top_up_orders/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/top_up_orders/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['amountPaid' => '0.00'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/top_up_orders/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
