<?php

namespace App\Tests\Players;

use App\Entity\Players\PlayerAchievement;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Players\Achievement;

class PlayerAchievementApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $depPlayer;
    private Achievement $depAchievement;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depPlayer = new Player();
        $this->depPlayer->setPublicId('00000000-0000-0000-0000-0000000000012');
        $this->depPlayer->setDisplayName('test2');
        $this->depPlayer->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->depPlayer);
        $this->depAchievement = new Achievement();
        $this->depAchievement->setName('test');
        $this->depAchievement->setDescription('test');
        $this->em->persist($this->depAchievement);

        $entity = new PlayerAchievement();
        $entity->setEarnedAt(new \DateTime('2024-01-01'));
        $entity->setPlayer($this->depPlayer);
        $entity->setAchievement($this->depAchievement);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/player_achievements');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/player_achievements/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

}
