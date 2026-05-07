<?php

namespace App\Tests\Cards;

use App\Entity\Cards\CardRuling;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class CardRulingApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new CardRuling();
        $entity->setRulingText('test');
        $entity->setPublishedAt(new \DateTime('2024-01-01'));
        $entity->setSource('test');
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/card_rulings');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/card_rulings', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'ruling_text' => 'test',
            'published_at' => new \DateTime('2024-01-01'),
            'source' => 'test',
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/card_rulings/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/card_rulings/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['ruling_text' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/card_rulings/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
