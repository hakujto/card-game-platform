<?php

namespace App\Tests\Cards;

use App\Entity\Cards\CardRuling;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;

class CardRulingApiTest extends WebTestCase
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
        $this->auxCardSet->setName('test');
        $this->auxCardSet->setCode('tB');
        $this->auxCardSet->setReleaseDate(new \DateTime('2024-01-01'));
        $this->auxCardSet->setTotalCards(1);
        $this->em->persist($this->auxCardSet);
        $this->depCard = new Card();
        $this->depCard->setPublicId('00000000-0000-0000-0000-0000000000013');
        $this->depCard->setName('test');
        $this->depCard->setManaColors('test');
        $this->depCard->setDescription('test');
        $this->depCard->setLegalFormats('test');
        $this->depCard->setSet($this->auxCardSet);
        $this->em->persist($this->depCard);

        $entity = new CardRuling();
        $entity->setRulingText('test');
        $entity->setPublishedAt(new \DateTime('2024-01-01'));
        $entity->setSource('test');
        $entity->setCard($this->depCard);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/card_rulings');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/card_rulings', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'rulingText' => 'test',
            'publishedAt' => '2024-01-01',
            'source' => 'test',
            'card' => (int) $this->depCard->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/card_rulings/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/card_rulings/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

}
