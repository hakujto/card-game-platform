<?php

namespace App\Tests\Cards;

use App\Entity\Cards\Card;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Cards\CardSet;

class CardApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private CardSet $depSet;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depSet = new CardSet();
        $this->em->persist($this->depSet);

        $entity = new Card();
        $entity->setName('test');
        $entity->setManaColors('test');
        $entity->setDescription('test');
        $entity->setLegalFormats('test');
        $entity->setSet($this->depSet);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/cards');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/cards', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'name' => 'test',
            'description' => 'test',
            'set' => (int) $this->depSet->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/cards/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/cards/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/cards/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenCreatureRequiresStatsViolated(): void
    {
        // Creature card must have attack and defense
        $this->client->request('POST', '/api/cards', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'rarity' => 'COMMON', 'manaCost' => 1, 'manaColors' => 'WHITE', 'description' => 'test', 'legalFormats' => 'STANDARD', 'isBanned' => true, 'isRestricted' => true, 'powerLevel' => 1, 'setId' => 1, 'cardType' => 'CREATURE', 'attack' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenPlaneswalkerRequiresLoyaltyViolated(): void
    {
        // Planeswalker card must have loyalty
        $this->client->request('POST', '/api/cards', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'rarity' => 'COMMON', 'manaCost' => 1, 'manaColors' => 'WHITE', 'description' => 'test', 'legalFormats' => 'STANDARD', 'isBanned' => true, 'isRestricted' => true, 'powerLevel' => 1, 'setId' => 1, 'cardType' => 'PLANESWALKER', 'loyalty' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenSpellOrArtifactNoLoyaltyViolated(): void
    {
        // Only Planeswalker cards can have loyalty
        $this->client->request('POST', '/api/cards', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'cardType' => 'CREATURE', 'rarity' => 'COMMON', 'manaCost' => 1, 'manaColors' => 'WHITE', 'description' => 'test', 'legalFormats' => 'STANDARD', 'isBanned' => true, 'isRestricted' => true, 'powerLevel' => 1, 'setId' => 1, 'loyalty' => 1])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenManaCostRangeViolated(): void
    {
        // mana_cost must be between 0 and 20
        $this->client->request('POST', '/api/cards', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'rarity' => 'COMMON', 'manaColors' => 'WHITE', 'description' => 'test', 'isRestricted' => true, 'powerLevel' => 1, 'setId' => 1, 'cardType' => 'CREATURE', 'attack' => 1, 'defense' => 1, 'cardType' => 'PLANESWALKER', 'loyalty' => 1, 'loyalty' => null, 'isBanned' => true, 'legalFormats' => "message", 'manaCost' => 21])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenPowerLevelRangeViolated(): void
    {
        // power_level must be between 1 and 10
        $this->client->request('POST', '/api/cards', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'rarity' => 'COMMON', 'manaCost' => 1, 'manaColors' => 'WHITE', 'description' => 'test', 'isRestricted' => true, 'setId' => 1, 'cardType' => 'CREATURE', 'attack' => 1, 'defense' => 1, 'cardType' => 'PLANESWALKER', 'loyalty' => 1, 'loyalty' => null, 'isBanned' => true, 'legalFormats' => "message", 'powerLevel' => 11])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenNotBannedAndRestrictedViolated(): void
    {
        // Card cannot be both banned and restricted at the same time
        $this->client->request('POST', '/api/cards', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'rarity' => 'COMMON', 'manaCost' => 1, 'manaColors' => 'WHITE', 'description' => 'test', 'powerLevel' => 1, 'setId' => 1, 'cardType' => 'CREATURE', 'attack' => 1, 'defense' => 1, 'cardType' => 'PLANESWALKER', 'loyalty' => 1, 'loyalty' => null, 'legalFormats' => "message", 'isBanned' => true, 'isRestricted' => true])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenBannedCardNotInLegalFormatsViolated(): void
    {
        // banned_card_not_in_legal_formats
        $this->client->request('POST', '/api/cards', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'cardType' => 'CREATURE', 'rarity' => 'COMMON', 'manaCost' => 1, 'manaColors' => 'WHITE', 'description' => 'test', 'legalFormats' => 'STANDARD', 'isRestricted' => true, 'powerLevel' => 1, 'setId' => 1, 'isBanned' => true])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
