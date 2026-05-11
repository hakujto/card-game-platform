<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\Season;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class SeasonApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new Season();
        $entity->setName('test');
        $entity->setStartDate(new \DateTime('2024-01-01'));
        $entity->setEndDate(new \DateTime('2024-01-01'));
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/seasons');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/seasons', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'name' => 'test',
            'startDate' => '2024-01-01',
            'endDate' => '2024-01-01',
            'isActive' => true,
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/seasons/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/seasons/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/seasons/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
