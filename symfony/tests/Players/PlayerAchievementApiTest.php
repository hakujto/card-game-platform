<?php

namespace App\Tests\Players;

use App\Entity\Players\PlayerAchievement;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;
use App\Entity\Players\Achievement;

class PlayerAchievementApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depPlayer;
    private Achievement $depAchievement;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->depPlayer = new Player();
        $this->depPlayer->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depPlayer);
        $this->depAchievement = new Achievement();
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

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/player_achievements', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'earnedAt' => '2024-01-01T00:00:00+00:00',
            'progress' => 1,
            'isCompleted' => true,
            'player' => (int) $this->depPlayer->getId(),
            'achievement' => (int) $this->depAchievement->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/player_achievements/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/player_achievements/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['earnedAt' => '2024-01-01T00:00:00+00:00'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/player_achievements/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

}
