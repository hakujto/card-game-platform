<?php

namespace App\Tests\Players;

use App\Entity\Players\Friendship;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;

class FriendshipApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $depRequester;
    private Player $depReceiver;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depRequester = new Player();
        $this->em->persist($this->depRequester);
        $this->depReceiver = new Player();
        $this->em->persist($this->depReceiver);

        $entity = new Friendship();
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setRequester($this->depRequester);
        $entity->setReceiver($this->depReceiver);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/friendships');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/friendships', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'requester' => (int) $this->depRequester->getId(),
            'receiver' => (int) $this->depReceiver->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/friendships/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/friendships/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['status' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/friendships/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

}
