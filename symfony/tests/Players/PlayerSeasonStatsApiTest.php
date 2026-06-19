<?php

namespace App\Tests\Players;

use App\Entity\Players\PlayerSeasonStats;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;

class PlayerSeasonStatsApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $depSeason;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depSeason = new Season();
        $this->depSeason->setName('test');
        $this->depSeason->setStartDate(new \DateTime('2024-01-01'));
        $this->depSeason->setEndDate(new \DateTime('2024-01-01'));
        $this->em->persist($this->depSeason);

        $entity = new PlayerSeasonStats();
        $entity->setSeason($this->depSeason);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/player_season_statses');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/player_season_statses/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

}
