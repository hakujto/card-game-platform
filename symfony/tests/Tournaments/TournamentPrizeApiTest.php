<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\TournamentPrize;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;
use App\Entity\Tournaments\Tournament;

class TournamentPrizeApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $auxPlayer;
    private Tournament $depTournament;

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
        $this->depTournament = new Tournament();
        $this->depTournament->setSeason($this->auxSeason);
        $this->depTournament->setOrganizer($this->auxPlayer);
        $this->em->persist($this->depTournament);

        $entity = new TournamentPrize();
        $entity->setPlacementFrom(1);
        $entity->setPlacementTo(1);
        $entity->setPrizeType('test');
        $entity->setTournament($this->depTournament);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/tournament_prizes');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/tournament_prizes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'placementFrom' => 1,
            'placementTo' => 1,
            'amount' => '0.00',
            'seasonPoints' => 1,
            'tournament' => (int) $this->depTournament->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/tournament_prizes/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/tournament_prizes/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['placementFrom' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/tournament_prizes/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
