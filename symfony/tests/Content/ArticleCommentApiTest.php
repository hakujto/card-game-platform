<?php

namespace App\Tests\Content;

use App\Entity\Content\ArticleComment;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;

class ArticleCommentApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $depAuthor;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->depAuthor = new Player();
        $this->depAuthor->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->depAuthor);

        $entity = new ArticleComment();
        $entity->setBody('test');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setAuthor($this->depAuthor);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/article_comments');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/article_comments', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'body' => 'test',
            'isHidden' => true,
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'author' => (int) $this->depAuthor->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/article_comments/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/article_comments/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['body' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/article_comments/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
