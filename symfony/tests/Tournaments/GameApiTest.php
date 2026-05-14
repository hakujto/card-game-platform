<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\Game;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Tournaments\MatchRecord;

class GameApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $auxPlayer;
    private MatchRecord $depMatch;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxPlayer = new Player();
        $this->em->persist($this->auxPlayer);
        $this->depMatch = new MatchRecord();
        $this->depMatch->setPlayer1($this->auxPlayer);
        $this->em->persist($this->depMatch);

        $entity = new Game();
        $entity->setGameNumber(1);
        $entity->setMatch($this->depMatch);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/games');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/games', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'gameNumber' => 1,
            'match' => (int) $this->depMatch->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/games/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/games/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['gameNumber' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/games/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenGameNumberRangeViolated(): void
    {
        // Game number must be between 1 and 3 (best-of-3)
        $this->client->request('POST', '/api/games', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['turnsPlayed' => 1, 'turnsPlayed' => 1, 'durationSeconds' => 1, 'durationSeconds' => 1, 'gameNumber' => 4])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenTurnsPlayedPositiveViolated(): void
    {
        // Turns played must be greater than zero
        $this->client->request('POST', '/api/games', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['gameNumber' => 1, 'turnsPlayed' => 1, 'turnsPlayed' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenDurationPositiveViolated(): void
    {
        // Game duration must be greater than zero
        $this->client->request('POST', '/api/games', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['gameNumber' => 1, 'durationSeconds' => 1, 'durationSeconds' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
