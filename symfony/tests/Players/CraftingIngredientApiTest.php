<?php

namespace App\Tests\Players;

use App\Entity\Players\CraftingIngredient;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Cards\CardSet;
use App\Entity\Cards\Card;
use App\Entity\Players\CraftingRecipe;

class CraftingIngredientApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private CardSet $auxCardSet;
    private Card $auxCard;
    private CraftingRecipe $depRecipe;
    private Card $depCard;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxCardSet = new CardSet();
        $this->em->persist($this->auxCardSet);
        $this->auxCard = new Card();
        $this->auxCard->setSet($this->auxCardSet);
        $this->em->persist($this->auxCard);
        $this->depRecipe = new CraftingRecipe();
        $this->depRecipe->setResultCard($this->auxCard);
        $this->em->persist($this->depRecipe);
        $this->depCard = new Card();
        $this->depCard->setSet($this->auxCardSet);
        $this->em->persist($this->depCard);

        $entity = new CraftingIngredient();
        $entity->setRecipe($this->depRecipe);
        $entity->setCard($this->depCard);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/crafting_ingredients');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/crafting_ingredients', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'quantity' => 1,
            'recipe' => (int) $this->depRecipe->getId(),
            'card' => (int) $this->depCard->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/crafting_ingredients/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/crafting_ingredients/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['quantity' => 1])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/crafting_ingredients/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
