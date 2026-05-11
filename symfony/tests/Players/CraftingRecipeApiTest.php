<?php

namespace App\Tests\Players;

use App\Entity\Players\CraftingRecipe;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;

class CraftingRecipeApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private CardSet $auxCardSet;
    private Card $depResultCard;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxCardSet = new CardSet();
        $this->em->persist($this->auxCardSet);
        $this->depResultCard = new Card();
        $this->depResultCard->setSet($this->auxCardSet);
        $this->em->persist($this->depResultCard);

        $entity = new CraftingRecipe();
        $entity->setDustCost(1);
        $entity->setResultCard($this->depResultCard);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/crafting_recipes');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/crafting_recipes', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'dustCost' => 1,
            'isAvailable' => true,
            'resultCard' => (int) $this->depResultCard->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/crafting_recipes/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/crafting_recipes/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['dustCost' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/crafting_recipes/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
