<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\AwardedPrize;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\Player;
use App\Entity\Tournaments\Tournament;
use App\Entity\Tournaments\TournamentPrize;

class AwardedPrizeApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private Player $auxPlayer;
    private Tournament $auxTournament;
    private TournamentPrize $depPrize;
    private Player $depPlayer;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayer = new Player();
        $this->em->persist($this->auxPlayer);
        $this->auxTournament = new Tournament();
        $this->auxTournament->setSeason($this->auxSeason);
        $this->auxTournament->setOrganizer($this->auxPlayer);
        $this->em->persist($this->auxTournament);
        $this->depPrize = new TournamentPrize();
        $this->depPrize->setTournament($this->auxTournament);
        $this->em->persist($this->depPrize);
        $this->depPlayer = new Player();
        $this->em->persist($this->depPlayer);

        $entity = new AwardedPrize();
        $entity->setFinalPlacement(1);
        $entity->setAwardedAt(new \DateTime('2024-01-01'));
        $entity->setPrize($this->depPrize);
        $entity->setPlayer($this->depPlayer);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/awarded_prizes');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/awarded_prizes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'finalPlacement' => 1,
            'awardedAt' => '2024-01-01T00:00:00+00:00',
            'prize' => (int) $this->depPrize->getId(),
            'player' => (int) $this->depPlayer->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/awarded_prizes/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/awarded_prizes/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['finalPlacement' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/awarded_prizes/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenClaimedRequiresClaimedAtViolated(): void
    {
        // Claimed prize must have a claimed_at timestamp
        $this->client->request('POST', '/api/awarded_prizes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['finalPlacement' => 1, 'awardedAt' => '2024-01-01T00:00:00+00:00', 'prizeId' => 1, 'playerId' => 1, 'claimed' => true, 'claimedAt' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenFinalPlacementPositiveViolated(): void
    {
        // Final placement must be greater than zero
        $this->client->request('POST', '/api/awarded_prizes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['awardedAt' => '2024-01-01T00:00:00+00:00', 'prizeId' => 1, 'playerId' => 1, 'claimed' => true, 'claimedAt' => '2024-01-01T00:00:00+00:00', 'finalPlacement' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
