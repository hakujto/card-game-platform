<?php

namespace App\Tests\Marketplace;

use App\Entity\Marketplace\CardPriceHistory;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;

class CardPriceHistoryApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private CardSet $auxCardSet;
    private Card $depCard;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxCardSet = new CardSet();
        $this->em->persist($this->auxCardSet);
        $this->depCard = new Card();
        $this->depCard->setSet($this->auxCardSet);
        $this->em->persist($this->depCard);

        $entity = new CardPriceHistory();
        $entity->setPriceDate(new \DateTime('2024-01-01'));
        $entity->setAvgPrice('0.00');
        $entity->setMinPrice('0.00');
        $entity->setMaxPrice('0.00');
        $entity->setVolume(1);
        $entity->setCard($this->depCard);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/card_price_histories');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/card_price_histories', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'priceDate' => '2024-01-01',
            'avgPrice' => '0.00',
            'minPrice' => '0.00',
            'maxPrice' => '0.00',
            'volume' => 1,
            'foil' => true,
            'card' => (int) $this->depCard->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/card_price_histories/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/card_price_histories/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['priceDate' => '2024-01-01'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/card_price_histories/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

}
