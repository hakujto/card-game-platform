<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\TournamentRegistration;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\Player;
use App\Entity\Tournaments\Tournament;
use App\Entity\Cards\Deck;
use App\Entity\User;

class TournamentRegistrationApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private User $ownerUser;
    private Player $ownerModel;
    private Season $auxSeason;
    private Player $auxPlayer;
    private Tournament $depTournament;
    private Deck $depDeck;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->ownerUser = new User();
        $this->ownerUser->setEmail('owner@example.com');
        $this->ownerUser->setPassword('test');
        $this->em->persist($this->ownerUser);
        $this->ownerModel = new Player();
        $this->ownerModel->setUser($this->ownerUser);
        $this->ownerModel->setPublicId('00000000-0000-0000-0000-0000000000011');
        $this->ownerModel->setDisplayName('test1');
        $this->ownerModel->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->ownerModel);
        $this->em->flush();
        $this->client->loginUser($this->ownerUser);

        $this->auxSeason = new Season();
        $this->auxSeason->setName('test');
        $this->auxSeason->setStartDate(new \DateTime('2024-01-01'));
        $this->auxSeason->setEndDate(new \DateTime('2024-01-01'));
        $this->em->persist($this->auxSeason);
        $this->auxPlayer = new Player();
        $this->auxPlayer->setPublicId('00000000-0000-0000-0000-0000000000013');
        $this->auxPlayer->setDisplayName('test3');
        $this->auxPlayer->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->auxPlayer);
        $this->depTournament = new Tournament();
        $this->depTournament->setPublicId('00000000-0000-0000-0000-0000000000014');
        $this->depTournament->setName('test');
        $this->depTournament->setMaxPlayers(1);
        $this->depTournament->setStartTime(new \DateTime('2024-01-01'));
        $this->depTournament->setCreatedAt(new \DateTime('2024-01-01'));
        $this->depTournament->setSeason($this->auxSeason);
        $this->depTournament->setOrganizer($this->auxPlayer);
        $this->em->persist($this->depTournament);
        $this->depDeck = new Deck();
        $this->depDeck->setName('test');
        $this->depDeck->setCreatedAt(new \DateTime('2024-01-01'));
        $this->depDeck->setUpdatedAt(new \DateTime('2024-01-01'));
        $this->depDeck->setPlayer($this->auxPlayer);
        $this->em->persist($this->depDeck);

        $entity = new TournamentRegistration();
        $entity->setRegisteredAt(new \DateTime('2024-01-01'));
        $entity->setTournament($this->depTournament);
        $entity->setDeck($this->depDeck);
        $entity->setPlayer($this->ownerModel);
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
            'deck' => (int) $this->depDeck->getId(),
            'player' => (int) $this->ownerModel->getId(),
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
