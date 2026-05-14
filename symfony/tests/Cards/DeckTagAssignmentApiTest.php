<?php

namespace App\Tests\Cards;

use App\Entity\Cards\DeckTagAssignment;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;
use App\Entity\Cards\Deck;
use App\Entity\Cards\DeckTag;

class DeckTagAssignmentApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $auxPlayer;
    private Deck $depDeck;
    private DeckTag $depTag;

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
        $this->depDeck = new Deck();
        $this->depDeck->setPlayer($this->auxPlayer);
        $this->em->persist($this->depDeck);
        $this->depTag = new DeckTag();
        $this->em->persist($this->depTag);

        $entity = new DeckTagAssignment();
        $entity->setDeck($this->depDeck);
        $entity->setTag($this->depTag);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/deck_tag_assignments');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/deck_tag_assignments', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'deck' => (int) $this->depDeck->getId(),
            'tag' => (int) $this->depTag->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/deck_tag_assignments/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/deck_tag_assignments/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/deck_tag_assignments/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

}
