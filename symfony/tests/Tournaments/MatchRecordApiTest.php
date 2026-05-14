<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\MatchRecord;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class MatchRecordApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depPlayer1;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->depPlayer1 = new Player();
        $this->depPlayer1->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depPlayer1);

        $entity = new MatchRecord();
        $entity->setPlayer1($this->depPlayer1);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/matches');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/matches', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'player1Wins' => 1,
            'player2Wins' => 1,
            'player1' => (int) $this->depPlayer1->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/matches/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/matches/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['tableNumber' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/matches/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenWinsNotNegativeViolated(): void
    {
        // Win counts must not be negative
        $this->client->request('POST', '/api/matches', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['player2Wins' => 1, 'status' => 'BYE', 'player2' => null, 'player1Wins' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenMaxThreeGamesViolated(): void
    {
        // Win counts cannot exceed 2 in a best-of-3 match
        $this->client->request('POST', '/api/matches', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['player2Wins' => 1, 'status' => 'BYE', 'player2' => null, 'player1Wins' => 3])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenByeHasNoPlayer2Violated(): void
    {
        // BYE match must not have a second player
        $this->client->request('POST', '/api/matches', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['player1Wins' => 1, 'player2Wins' => 1, 'status' => 'BYE', 'player2' => 'test'])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
