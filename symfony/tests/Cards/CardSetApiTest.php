<?php

namespace App\Tests\Cards;

use App\Entity\Cards\CardSet;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class CardSetApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new CardSet();
        $entity->setName('test');
        $entity->setCode('test');
        $entity->setReleaseDate(new \DateTime('2024-01-01'));
        $entity->setTotalCards(1);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/card_sets');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/card_sets', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'name' => 'test',
            'code' => 'test',
            'releaseDate' => '2024-01-01',
            'totalCards' => 1,
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/card_sets/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/card_sets/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/card_sets/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenTotalCardsPositiveViolated(): void
    {
        // Card set must have at least one card
        $this->client->request('POST', '/api/card_sets', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'code' => 'test', 'releaseDate' => '2024-01-01', 'setType' => 'CORE', 'rotationDate' => '2024-01-01', 'isRotated' => true, 'rotationDate' => '2024-01-01', 'totalCards' => 0])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenRotationDateAfterReleaseViolated(): void
    {
        // Rotation date must be after release date
        $this->client->request('POST', '/api/card_sets', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'code' => 'test', 'releaseDate' => '2024-01-01', 'setType' => 'CORE', 'totalCards' => 1, 'isRotated' => true, 'rotationDate' => '2024-01-01', 'rotationDate' => '2024-01-01'])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenRotatedSetHasRotationDateViolated(): void
    {
        // Rotated set must have a rotation date
        $this->client->request('POST', '/api/card_sets', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test', 'code' => 'test', 'releaseDate' => '2024-01-01', 'setType' => 'CORE', 'totalCards' => 1, 'isRotated' => true, 'rotationDate' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
