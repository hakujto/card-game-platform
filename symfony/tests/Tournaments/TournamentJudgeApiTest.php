<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\TournamentJudge;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\Player;
use App\Entity\Tournaments\Tournament;

class TournamentJudgeApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private Player $auxPlayer;
    private Tournament $depTournament;
    private Player $depPlayer;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayer = new Player();
        $this->em->persist($this->auxPlayer);
        $this->depTournament = new Tournament();
        $this->depTournament->setSeason($this->auxSeason);
        $this->depTournament->setOrganizer($this->auxPlayer);
        $this->em->persist($this->depTournament);
        $this->depPlayer = new Player();
        $this->em->persist($this->depPlayer);

        $entity = new TournamentJudge();
        $entity->setTournament($this->depTournament);
        $entity->setPlayer($this->depPlayer);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/tournament_judges');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/tournament_judges', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'tournament' => (int) $this->depTournament->getId(),
            'player' => (int) $this->depPlayer->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/tournament_judges/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/tournament_judges/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['role' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/tournament_judges/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

}
