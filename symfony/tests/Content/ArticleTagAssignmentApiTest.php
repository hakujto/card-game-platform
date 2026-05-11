<?php

namespace App\Tests\Content;

use App\Entity\Content\ArticleTagAssignment;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Tournaments\Season;
use App\Entity\Players\PlayerSeasonStats;
use App\Entity\Players\Player;
use App\Entity\Content\ArticleComment;
use App\Entity\Content\Article;
use App\Entity\Content\ArticleTag;

class ArticleTagAssignmentApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Season $auxSeason;
    private PlayerSeasonStats $auxPlayerSeasonStats;
    private Player $auxPlayer;
    private ArticleComment $auxArticleComment;
    private Article $depArticle;
    private ArticleTag $depTag;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxSeason = new Season();
        $this->em->persist($this->auxSeason);
        $this->auxPlayerSeasonStats = new PlayerSeasonStats();
        $this->auxPlayerSeasonStats->setSeason($this->auxSeason);
        $this->em->persist($this->auxPlayerSeasonStats);
        $this->auxPlayer = new Player();
        $this->auxPlayer->setSeasonStats($this->auxPlayerSeasonStats);
        $this->em->persist($this->auxPlayer);
        $this->auxArticleComment = new ArticleComment();
        $this->auxArticleComment->setAuthor($this->auxPlayer);
        $this->em->persist($this->auxArticleComment);
        $this->depArticle = new Article();
        $this->depArticle->setAuthor($this->auxPlayer);
        $this->depArticle->setComments($this->auxArticleComment);
        $this->em->persist($this->depArticle);
        $this->depTag = new ArticleTag();
        $this->em->persist($this->depTag);

        $entity = new ArticleTagAssignment();
        $entity->setArticle($this->depArticle);
        $entity->setTag($this->depTag);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/article_tag_assignments');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/article_tag_assignments', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'article' => (int) $this->depArticle->getId(),
            'tag' => (int) $this->depTag->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/article_tag_assignments/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/article_tag_assignments/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/article_tag_assignments/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
