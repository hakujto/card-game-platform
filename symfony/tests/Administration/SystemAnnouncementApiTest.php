<?php

namespace App\Tests\Administration;

use App\Entity\Administration\SystemAnnouncement;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class SystemAnnouncementApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new SystemAnnouncement();
        $entity->setTitle('test');
        $entity->setBody('test');
        $entity->setShowFrom(new \DateTime('2024-01-01'));
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/system_announcements');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/system_announcements', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'title' => 'test',
            'body' => 'test',
            'isActive' => true,
            'showFrom' => '2024-01-01T00:00:00+00:00',
            'createdAt' => '2024-01-01T00:00:00+00:00',
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/system_announcements/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/system_announcements/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['title' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/system_announcements/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
