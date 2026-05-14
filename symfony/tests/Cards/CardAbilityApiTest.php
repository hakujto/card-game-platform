<?php

namespace App\Tests\Cards;

use App\Entity\Cards\CardAbility;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;

class CardAbilityApiTest extends WebTestCase
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

        $entity = new CardAbility();
        $entity->setAbilityText('test');
        $entity->setCard($this->depCard);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/card_abilities');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/card_abilities', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'abilityText' => 'test',
            'card' => (int) $this->depCard->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/card_abilities/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/card_abilities/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['abilityType' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/card_abilities/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenKeywordAbilityRequiresKeywordViolated(): void
    {
        // Keyword ability must have a keyword name
        $this->client->request('POST', '/api/card_abilities', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['abilityText' => 'test', 'abilityType' => 'KEYWORD', 'keyword' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
