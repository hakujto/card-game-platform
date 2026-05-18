<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\TournamentRegistration;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\Player;
use App\Entity\Tournaments\Tournament;
use App\Entity\Cards\Deck;

class TournamentRegistrationApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private Player $auxPlayer;
    private Tournament $depTournament;
    private Player $depPlayer;
    private Deck $depDeck;

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
        $this->depDeck = new Deck();
        $this->depDeck->setPlayer($this->auxPlayer);
        $this->em->persist($this->depDeck);

        $entity = new TournamentRegistration();
        $entity->setRegisteredAt(new \DateTime('2024-01-01'));
        $entity->setTournament($this->depTournament);
        $entity->setPlayer($this->depPlayer);
        $entity->setDeck($this->depDeck);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/tournament_registrations');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/tournament_registrations', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'registeredAt' => '2024-01-01T00:00:00+00:00',
            'tournament' => (int) $this->depTournament->getId(),
            'player' => (int) $this->depPlayer->getId(),
            'deck' => (int) $this->depDeck->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/tournament_registrations/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/tournament_registrations/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/tournament_registrations/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenPointsEarnedNotNegativeViolated(): void
    {
        // Points earned must not be negative
        $this->client->request('POST', '/api/tournament_registrations', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'REGISTERED', 'registeredAt' => '2024-01-01T00:00:00+00:00', 'tournamentId' => 1, 'playerId' => 1, 'deckId' => 1, 'finalStanding' => 1, 'finalStanding' => 1, 'seed' => 1, 'seed' => 1, 'pointsEarned' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenFinalStandingPositiveViolated(): void
    {
        // Final standing must be greater than zero
        $this->client->request('POST', '/api/tournament_registrations', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'REGISTERED', 'pointsEarned' => 1, 'registeredAt' => '2024-01-01T00:00:00+00:00', 'tournamentId' => 1, 'playerId' => 1, 'deckId' => 1, 'finalStanding' => 1, 'finalStanding' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenSeedPositiveViolated(): void
    {
        // Seed must be greater than zero
        $this->client->request('POST', '/api/tournament_registrations', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'REGISTERED', 'pointsEarned' => 1, 'registeredAt' => '2024-01-01T00:00:00+00:00', 'tournamentId' => 1, 'playerId' => 1, 'deckId' => 1, 'seed' => 1, 'seed' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
