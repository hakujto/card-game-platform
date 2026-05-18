<?php

namespace App\Tests\Content;

use App\Entity\Content\Article;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;

class ArticleApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $depAuthor;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depAuthor = new Player();
        $this->em->persist($this->depAuthor);

        $entity = new Article();
        $entity->setTitle('test');
        $entity->setSlug('test');
        $entity->setBody('test');
        $entity->setCreatedAt(new \DateTime('2024-01-01'));
        $entity->setUpdatedAt(new \DateTime('2024-01-01'));
        $entity->setAuthor($this->depAuthor);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/articles');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/articles', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'title' => 'test',
            'slug' => 'test',
            'body' => 'test',
            'createdAt' => '2024-01-01T00:00:00+00:00',
            'updatedAt' => '2024-01-01T00:00:00+00:00',
            'author' => (int) $this->depAuthor->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/articles/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/articles/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['title' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/articles/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenPublishedRequiresPublishedAtViolated(): void
    {
        // Published article must have a published_at timestamp
        $this->client->request('POST', '/api/articles', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['title' => 'test', 'slug' => 'test', 'body' => 'test', 'articleType' => 'GUIDE', 'viewCount' => 1, 'createdAt' => '2024-01-01T00:00:00+00:00', 'updatedAt' => '2024-01-01T00:00:00+00:00', 'authorId' => 1, 'status' => 'PUBLISHED', 'publishedAt' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenViewCountNotNegativeViolated(): void
    {
        // Article view count must not be negative
        $this->client->request('POST', '/api/articles', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['title' => 'test', 'slug' => 'test', 'body' => 'test', 'articleType' => 'GUIDE', 'createdAt' => '2024-01-01T00:00:00+00:00', 'updatedAt' => '2024-01-01T00:00:00+00:00', 'authorId' => 1, 'status' => 'PUBLISHED', 'publishedAt' => '2024-01-01T00:00:00+00:00', 'viewCount' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
