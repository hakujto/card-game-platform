<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\AwardedPrize;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class AwardedPrizeApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new AwardedPrize();
        $entity->setFinalPlacement(1);
        $entity->setAwardedAt(new \DateTime('2024-01-01'));
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/awarded_prizes');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/awarded_prizes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'final_placement' => 1,
            'awarded_at' => new \DateTime('2024-01-01'),
            'claimed' => true,
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/awarded_prizes/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/awarded_prizes/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['final_placement' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/awarded_prizes/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
