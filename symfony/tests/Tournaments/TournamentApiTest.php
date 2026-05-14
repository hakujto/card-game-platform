<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\Tournament;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\Player;

class TournamentApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $depSeason;
    private Player $depOrganizer;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depSeason = new Season();
        $this->em->persist($this->depSeason);
        $this->depOrganizer = new Player();
        $this->em->persist($this->depOrganizer);

        $entity = new Tournament();
        $entity->setName('test');
        $entity->setMaxPlayers(2);
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
            'maxPlayers' => 2,
            'startTime' => '2024-01-01T00:00:00+00:00',
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

    public function testCreateFailsWhenMaxPlayersPositiveViolated(): void
    {
        // Tournament must allow between 2 and 512 players
        $this->client->request('POST', '/api/tournaments', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'format' => 'STANDARD', 'tournamentType' => 'SWISS', 'status' => 'DRAFT', 'entryFee' => '0.00', 'prizePool' => '0.00', 'startTime' => '2024-01-01T00:00:00+00:00', 'isOnline' => true, 'createdAt' => '2024-01-01T00:00:00+00:00', 'endTime' => '2024-01-01T00:00:00+00:00', 'maxPlayers' => 513])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenEntryFeeNotNegativeViolated(): void
    {
        // Entry fee must not be negative
        $this->client->request('POST', '/api/tournaments', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'format' => 'STANDARD', 'tournamentType' => 'SWISS', 'status' => 'DRAFT', 'maxPlayers' => 1, 'prizePool' => '0.00', 'startTime' => '2024-01-01T00:00:00+00:00', 'isOnline' => true, 'createdAt' => '2024-01-01T00:00:00+00:00', 'endTime' => '2024-01-01T00:00:00+00:00', 'entryFee' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenPrizePoolNotNegativeViolated(): void
    {
        // Prize pool must not be negative
        $this->client->request('POST', '/api/tournaments', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'format' => 'STANDARD', 'tournamentType' => 'SWISS', 'status' => 'DRAFT', 'maxPlayers' => 1, 'entryFee' => '0.00', 'startTime' => '2024-01-01T00:00:00+00:00', 'isOnline' => true, 'createdAt' => '2024-01-01T00:00:00+00:00', 'endTime' => '2024-01-01T00:00:00+00:00', 'prizePool' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenEndTimeAfterStartViolated(): void
    {
        // End time must be after start time
        $this->client->request('POST', '/api/tournaments', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'format' => 'STANDARD', 'tournamentType' => 'SWISS', 'status' => 'DRAFT', 'maxPlayers' => 1, 'entryFee' => '0.00', 'prizePool' => '0.00', 'startTime' => '2024-01-01T00:00:00+00:00', 'isOnline' => true, 'createdAt' => '2024-01-01T00:00:00+00:00', 'endTime' => '2024-01-01T00:00:00+00:00', 'endTime' => '2024-01-01T00:00:00+00:00'])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
