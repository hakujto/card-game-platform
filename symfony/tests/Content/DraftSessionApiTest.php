<?php

namespace App\Tests\Content;

use App\Entity\Content\DraftSession;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Cards\CardSet;

class DraftSessionApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private CardSet $depCardSet;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depCardSet = new CardSet();
        $this->em->persist($this->depCardSet);

        $entity = new DraftSession();
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setCardSet($this->depCardSet);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/draft_sessions');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/draft_sessions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'cardSet' => (int) $this->depCardSet->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/draft_sessions/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/draft_sessions/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/draft_sessions/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenSeatsRangeViolated(): void
    {
        // Draft session must have between 2 and 16 seats
        $this->client->request('POST', '/api/draft_sessions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['draftType' => 'BOOSTER', 'timePerPickSeconds' => 1, 'createdAt' => '2024-01-01T00:00:00+00:00', 'cardSetId' => 1, 'completedAt' => '2024-01-01T00:00:00+00:00', 'status' => 'COMPLETED', 'seats' => 17])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenCompletedAtRequiresCompletedStatusViolated(): void
    {
        // completed_at can only be set when draft status is Completed
        $this->client->request('POST', '/api/draft_sessions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'WAITINGFORPLAYERS', 'draftType' => 'BOOSTER', 'seats' => 1, 'timePerPickSeconds' => 1, 'createdAt' => '2024-01-01T00:00:00+00:00', 'cardSetId' => 1, 'completedAt' => '2024-01-01T00:00:00+00:00'])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenTimePerPickPositiveViolated(): void
    {
        // Time per pick must be greater than zero
        $this->client->request('POST', '/api/draft_sessions', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['draftType' => 'BOOSTER', 'seats' => 1, 'createdAt' => '2024-01-01T00:00:00+00:00', 'cardSetId' => 1, 'completedAt' => '2024-01-01T00:00:00+00:00', 'status' => 'COMPLETED', 'timePerPickSeconds' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }
    public function testTransitionWaitingForPlayersToDraftingSucceeds(): void
    {
        // Arrange: set entity to 'WaitingForPlayers' state
        $entity = $this->em->find(DraftSession::class, $this->entityId);
        $entity->setStatus('WaitingForPlayers');
        $this->em->flush();

        $this->client->request('PATCH', '/api/draft_sessions/' . $this->entityId . '/transitions/waitingforplayers-to-drafting');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Drafting', $data['status'] ?? null);
    }

    public function testTransitionDraftingToCompletedSucceeds(): void
    {
        // Arrange: set entity to 'Drafting' state
        $entity = $this->em->find(DraftSession::class, $this->entityId);
        $entity->setStatus('Drafting');
        $this->em->flush();

        $this->client->request('PATCH', '/api/draft_sessions/' . $this->entityId . '/transitions/drafting-to-completed');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Completed', $data['status'] ?? null);
    }

    public function testTransitionDraftingToAbandonedSucceeds(): void
    {
        // Arrange: set entity to 'Drafting' state
        $entity = $this->em->find(DraftSession::class, $this->entityId);
        $entity->setStatus('Drafting');
        $this->em->flush();

        $this->client->request('PATCH', '/api/draft_sessions/' . $this->entityId . '/transitions/drafting-to-abandoned');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Abandoned', $data['status'] ?? null);
    }

    public function testTransitionWaitingForPlayersToAbandonedSucceeds(): void
    {
        // Arrange: set entity to 'WaitingForPlayers' state
        $entity = $this->em->find(DraftSession::class, $this->entityId);
        $entity->setStatus('WaitingForPlayers');
        $this->em->flush();

        $this->client->request('PATCH', '/api/draft_sessions/' . $this->entityId . '/transitions/waitingforplayers-to-abandoned');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Abandoned', $data['status'] ?? null);
    }

    public function testTransitionCompletedToDraftingIsDenied(): void
    {
        // Arrange: entity exists (any state)
        $this->client->request('PATCH', '/api/draft_sessions/' . $this->entityId . '/transitions/completed-to-drafting');
        $this->assertResponseStatusCodeSame(409);
    }

    public function testTransitionAbandonedToDraftingIsDenied(): void
    {
        // Arrange: entity exists (any state)
        $this->client->request('PATCH', '/api/draft_sessions/' . $this->entityId . '/transitions/abandoned-to-drafting');
        $this->assertResponseStatusCodeSame(409);
    }
}
