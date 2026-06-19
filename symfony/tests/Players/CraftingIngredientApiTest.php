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
        $this->auxCardSet->setName('test');
        $this->auxCardSet->setCode('test2');
        $this->auxCardSet->setReleaseDate(new \DateTime('2024-01-01'));
        $this->auxCardSet->setTotalCards(1);
        $this->em->persist($this->auxCardSet);
        $this->auxCard = new Card();
        $this->auxCard->setName('test');
        $this->auxCard->setManaColors('test');
        $this->auxCard->setDescription('test');
        $this->auxCard->setLegalFormats('test');
        $this->auxCard->setSet($this->auxCardSet);
        $this->em->persist($this->auxCard);
        $this->depRecipe = new CraftingRecipe();
        $this->depRecipe->setDustCost(1);
        $this->depRecipe->setResultCard($this->auxCard);
        $this->em->persist($this->depRecipe);
        $this->depCard = new Card();
        $this->depCard->setName('test');
        $this->depCard->setManaColors('test');
        $this->depCard->setDescription('test');
        $this->depCard->setLegalFormats('test');
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

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/crafting_ingredients/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

}
