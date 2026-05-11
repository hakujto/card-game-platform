<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\Order;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;
use App\Entity\Marketplace\Product;
use App\Entity\Marketplace\OrderItem;

class OrderApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depPlayer;
    private Product $auxProduct;
    private OrderItem $depItems;

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
        $this->auxProduct = new Product();
        $this->em->persist($this->auxProduct);
        $this->depItems = new OrderItem();
        $this->depItems->setProduct($this->auxProduct);
        $this->em->persist($this->depItems);

        $entity = new Order();
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setPlayer($this->depPlayer);
        $entity->setItems($this->depItems);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/orders');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/orders', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'total' => '0.00',
            'discountApplied' => '0.00',
            'currency' => 'test',
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'player' => (int) $this->depPlayer->getId(),
            'items' => (int) $this->depItems->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/orders/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/orders/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/orders/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
