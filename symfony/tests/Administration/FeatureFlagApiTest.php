<?php

namespace App\Tests\Administration;

use App\Entity\Administration\FeatureFlag;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class FeatureFlagApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new FeatureFlag();
        $entity->setKey('test');
        $entity->setUpdatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/feature_flags');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/feature_flags', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'key' => 'test',
            'isEnabled' => true,
            'rolloutPercent' => 1,
            'updatedAt' => '2024-01-01T00:00:00+00:00',
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/feature_flags/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/feature_flags/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['key' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/feature_flags/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
