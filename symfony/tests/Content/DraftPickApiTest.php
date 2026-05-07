<?php

namespace App\Tests\Content;

use App\Entity\Content\DraftPick;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class DraftPickApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new DraftPick();
        $entity->setPickNumber(1);
        $entity->setPackNumber(1);
        $entity->setPickedAt(new \DateTime('2024-01-01'));
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/draft_picks');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/draft_picks', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'pick_number' => 1,
            'pack_number' => 1,
            'picked_at' => new \DateTime('2024-01-01'),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/draft_picks/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/draft_picks/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['pick_number' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/draft_picks/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
