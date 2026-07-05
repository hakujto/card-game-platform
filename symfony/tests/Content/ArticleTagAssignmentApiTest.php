<?php

namespace App\Tests\Content;

use App\Entity\Content\ArticleTagAssignment;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\Content\Article;
use App\Entity\Content\ArticleTag;

class ArticleTagAssignmentApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $auxPlayer;
    private Article $depArticle;
    private ArticleTag $depTag;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->auxPlayer = new Player();
        $this->auxPlayer->setPublicId('00000000-0000-0000-0000-0000000000012');
        $this->auxPlayer->setDisplayName('test2');
        $this->auxPlayer->setCreatedAt(new \DateTime('2024-01-01'));
        $this->em->persist($this->auxPlayer);
        $this->depArticle = new Article();
        $this->depArticle->setTitle('test');
        $this->depArticle->setSlug('test3');
        $this->depArticle->setBody('test');
        $this->depArticle->setCreatedAt(new \DateTime('2024-01-01'));
        $this->depArticle->setUpdatedAt(new \DateTime('2024-01-01'));
        $this->depArticle->setAuthor($this->auxPlayer);
        $this->em->persist($this->depArticle);
        $this->depTag = new ArticleTag();
        $this->depTag->setName('test');
        $this->depTag->setSlug('test4');
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

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/article_tag_assignments/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

}
