<?php

namespace App\Tests\Cards;

use App\Entity\Cards\Card;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Cards\CardSet;

class CardApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private CardSet $depSet;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depSet = new CardSet();
        $this->em->persist($this->depSet);

        $entity = new Card();
        $entity->setName('test');
        $entity->setManaColors('test');
        $entity->setDescription('test');
        $entity->setLegalFormats('test');
        $entity->setSet($this->depSet);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/cards');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/cards', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'name' => 'test',
            'manaCost' => 1,
            'description' => 'test',
            'isBanned' => true,
            'isRestricted' => true,
            'powerLevel' => 1,
            'set' => (int) $this->depSet->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/cards/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/cards/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/cards/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
