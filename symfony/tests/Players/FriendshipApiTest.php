<?php

namespace App\Tests\Players;

use App\Entity\Players\Friendship;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\User;

class FriendshipApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private User $ownerUser;
    private Player $ownerModel;
    private Player $depReceiver;

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

        $this->depReceiver = new Player();
        $this->depReceiver->setPublicId('00000000-0000-0000-0000-0000000000012');
        $this->depReceiver->setDisplayName('test2');
        $this->depReceiver->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->depReceiver);

        $entity = new Friendship();
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setReceiver($this->depReceiver);
        $entity->setRequester($this->ownerModel);
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
            'receiver' => (int) $this->depReceiver->getId(),
            'requester' => (int) $this->ownerModel->getId(),
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

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/friendships/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

}
