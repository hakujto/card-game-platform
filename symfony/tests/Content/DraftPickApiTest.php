<?php

namespace App\Tests\Content;

use App\Entity\Content\DraftPick;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Content\DraftParticipant;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;

class DraftPickApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $auxPlayer;
    private DraftParticipant $depParticipant;
    private CardSet $auxCardSet;
    private Card $depCard;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxPlayer = new Player();
        $this->em->persist($this->auxPlayer);
        $this->depParticipant = new DraftParticipant();
        $this->depParticipant->setPlayer($this->auxPlayer);
        $this->em->persist($this->depParticipant);
        $this->auxCardSet = new CardSet();
        $this->em->persist($this->auxCardSet);
        $this->depCard = new Card();
        $this->depCard->setSet($this->auxCardSet);
        $this->em->persist($this->depCard);

        $entity = new DraftPick();
        $entity->setPickNumber(1);
        $entity->setPackNumber(1);
        $entity->setPickedAt(new \DateTime('2024-01-01'));
        $entity->setParticipant($this->depParticipant);
        $entity->setCard($this->depCard);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/draft_picks');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/draft_picks', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'pickNumber' => 1,
            'packNumber' => 1,
            'pickedAt' => '2024-01-01T00:00:00+00:00',
            'participant' => (int) $this->depParticipant->getId(),
            'card' => (int) $this->depCard->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/draft_picks/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/draft_picks/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['pickNumber' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/draft_picks/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenPickNumberPositiveViolated(): void
    {
        // Pick number must be greater than zero
        $this->client->request('POST', '/api/draft_picks', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['packNumber' => 1, 'pickedAt' => '2024-01-01T00:00:00+00:00', 'participantId' => 1, 'cardId' => 1, 'pickNumber' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenPackNumberRangeViolated(): void
    {
        // Pack number must be between 1 and 3
        $this->client->request('POST', '/api/draft_picks', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['pickNumber' => 1, 'pickedAt' => '2024-01-01T00:00:00+00:00', 'participantId' => 1, 'cardId' => 1, 'packNumber' => 4])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
