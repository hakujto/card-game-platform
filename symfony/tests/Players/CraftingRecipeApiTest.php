<?php

namespace App\Tests\Players;

use App\Entity\Players\CraftingRecipe;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class CraftingRecipeApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new CraftingRecipe();
        $entity->setDustCost(1);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/crafting_recipes');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/crafting_recipes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'dust_cost' => 1,
            'is_available' => true,
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/crafting_recipes/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/crafting_recipes/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['dust_cost' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/crafting_recipes/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
