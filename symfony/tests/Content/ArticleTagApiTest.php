<?php

namespace App\Tests\Content;

use App\Entity\Content\ArticleTag;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;

class ArticleTagApiTest extends WebTestCase
{
    private EntityManagerInterface $em;
    private int $entityId;

    protected function setUp(): void
    {
        $client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $entity = new ArticleTag();
        $entity->setName('test');
        $entity->setSlug('test');
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/article_tags');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $client = static::createClient();
        $client->request('POST', '/api/article_tags', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'name' => 'test',
            'slug' => 'test',
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $client = static::createClient();
        $client->request('GET', '/api/article_tags/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $client = static::createClient();
        $client->request('PATCH', '/api/article_tags/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['name' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $client = static::createClient();
        $client->request('DELETE', '/api/article_tags/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }
}
