<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\Tournament;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class TournamentApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $depSeason;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depOrganizer;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depSeason = new Season();
        $this->em->persist($this->depSeason);
        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->depOrganizer = new Player();
        $this->depOrganizer->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depOrganizer);

        $entity = new Tournament();
        $entity->setName('test');
        $entity->setMaxPlayers(1);
        $entity->setStartTime(new \DateTime('2024-01-01'));
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setSeason($this->depSeason);
        $entity->setOrganizer($this->depOrganizer);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/tournaments');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/tournaments', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'name' => 'test',
            'maxPlayers' => 1,
            'entryFee' => '0.00',
            'prizePool' => '0.00',
            'startTime' => '2024-01-01T00:00:00+00:00',
            'isOnline' => true,
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'season' => (int) $this->depSeason->getId(),
            'organizer' => (int) $this->depOrganizer->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/tournaments/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/tournaments/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/tournaments/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
