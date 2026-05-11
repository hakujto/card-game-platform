<?php

namespace App\Tests\Content;

use App\Entity\Content\DraftSession;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Cards\CardSet;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;
use App\Entity\Content\DraftParticipant;

class DraftSessionApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private CardSet $depCardSet;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $auxPlayer;
    private DraftParticipant $depParticipants;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depCardSet = new CardSet();
        $this->em->persist($this->depCardSet);
        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->auxPlayer = new Player();
        $this->auxPlayer->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->auxPlayer);
        $this->depParticipants = new DraftParticipant();
        $this->depParticipants->setPlayer($this->auxPlayer);
        $this->em->persist($this->depParticipants);

        $entity = new DraftSession();
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setCardSet($this->depCardSet);
        $entity->setParticipants($this->depParticipants);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/draft_sessions');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/draft_sessions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'seats' => 1,
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'cardSet' => (int) $this->depCardSet->getId(),
            'participants' => (int) $this->depParticipants->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/draft_sessions/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/draft_sessions/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/draft_sessions/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
