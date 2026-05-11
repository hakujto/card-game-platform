<?php

namespace App\Tests\Economy;

use App\Entity\Economy\TopUpPackage;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class TopUpPackageApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new TopUpPackage();
        $entity->setName('test');
        $entity->setPrice('0.00');
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/top_up_packages');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/top_up_packages', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'name' => 'test',
            'price' => '0.00',
            'currency' => 'test',
            'creditsAmount' => '0.00',
            'gemsAmount' => 1,
            'bonusPercent' => 1,
            'isActive' => true,
            'featured' => true,
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/top_up_packages/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/top_up_packages/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/top_up_packages/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
