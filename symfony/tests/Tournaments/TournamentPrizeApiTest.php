<?php

namespace App\Tests\Tournaments;

use App\Entity\Tournaments\TournamentPrize;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class TournamentPrizeApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new TournamentPrize();
        $entity->setPlacementFrom(1);
        $entity->setPlacementTo(1);
        $entity->setPrizeType('test');
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/tournament_prizes');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/tournament_prizes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'placement_from' => 1,
            'placement_to' => 1,
            'amount' => '0.00',
            'season_points' => 1,
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/tournament_prizes/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/tournament_prizes/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['placement_from' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/tournament_prizes/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
