<?php

namespace App\Tests\Content;

use App\Entity\Content\Article;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;
use App\Entity\User;

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
        $this->depAuthor->setDisplayName('test2');
        $this->depAuthor->setCreatedAt(new \DateTime('2024-01-01'));
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

    public function testSearchReturns200(): void
    {
        $this->client->request('GET', '/api/articles?q=test');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/articles', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'title' => 'test',
            'slug' => 'test2',
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

    public function testCreateFailsWhenPublishedRequiresPublishedAtViolated(): void
    {
        // Published article must have a published_at timestamp
        $this->client->request('POST', '/api/articles', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['title' => 'test', 'slug' => 'test', 'body' => 'test', 'articleType' => 'GUIDE', 'language' => 'EN', 'viewCount' => 1, 'likesCount' => 1, 'isFeatured' => true, 'createdAt' => '2024-01-01T00:00:00+00:00', 'updatedAt' => '2024-01-01T00:00:00+00:00', 'authorId' => 1, 'status' => 'PUBLISHED', 'publishedAt' => null])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenViewCountNotNegativeViolated(): void
    {
        // Article view count must not be negative
        $this->client->request('POST', '/api/articles', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['title' => 'test', 'slug' => 'test', 'body' => 'test', 'articleType' => 'GUIDE', 'language' => 'EN', 'likesCount' => 1, 'isFeatured' => true, 'createdAt' => '2024-01-01T00:00:00+00:00', 'updatedAt' => '2024-01-01T00:00:00+00:00', 'authorId' => 1, 'status' => 'PUBLISHED', 'publishedAt' => '2024-01-01T00:00:00+00:00', 'viewCount' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }

    public function testCreateFailsWhenLikesCountNotNegativeViolated(): void
    {
        // Article likes count must not be negative
        $this->client->request('POST', '/api/articles', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['title' => 'test', 'slug' => 'test', 'body' => 'test', 'articleType' => 'GUIDE', 'language' => 'EN', 'viewCount' => 1, 'isFeatured' => true, 'createdAt' => '2024-01-01T00:00:00+00:00', 'updatedAt' => '2024-01-01T00:00:00+00:00', 'authorId' => 1, 'status' => 'PUBLISHED', 'publishedAt' => '2024-01-01T00:00:00+00:00', 'likesCount' => -1])
        );
        $this->assertResponseStatusCodeSame(422);
    }
    public function testTransitionDraftToPublishedSucceeds(): void
    {
        $user = new User();
        $user->setEmail('draftToPublished@example.com');
        $user->setPassword('test');
        $user->setRoles(['ROLE_EDITOR', 'ROLE_ADMIN']);
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $entity = $this->em->find(Article::class, $this->entityId);
        $entity->setStatus('Draft');
        $entity->setTitle('test'); // @on: title != null
        $entity->setBody('test'); // @on: body != null
        $this->em->flush();

        $this->client->request('PATCH', '/api/articles/' . $this->entityId . '/transitions/draft-to-published');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Published', $data['status'] ?? null);
    }

    public function testTransitionDraftToPublishedDeniedForWrongRole(): void
    {
        $user = new User();
        $user->setEmail('draftToPublished.wrong@example.com');
        $user->setPassword('test');
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $this->client->request('PATCH', '/api/articles/' . $this->entityId . '/transitions/draft-to-published');
        $this->assertResponseStatusCodeSame(403);
    }

    public function testTransitionPublishedToArchivedSucceeds(): void
    {
        $user = new User();
        $user->setEmail('publishedToArchived@example.com');
        $user->setPassword('test');
        $user->setRoles(['ROLE_EDITOR', 'ROLE_ADMIN']);
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $entity = $this->em->find(Article::class, $this->entityId);
        $entity->setStatus('Published');
        $this->em->flush();

        $this->client->request('PATCH', '/api/articles/' . $this->entityId . '/transitions/published-to-archived');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Archived', $data['status'] ?? null);
    }

    public function testTransitionPublishedToArchivedDeniedForWrongRole(): void
    {
        $user = new User();
        $user->setEmail('publishedToArchived.wrong@example.com');
        $user->setPassword('test');
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $this->client->request('PATCH', '/api/articles/' . $this->entityId . '/transitions/published-to-archived');
        $this->assertResponseStatusCodeSame(403);
    }

    public function testTransitionArchivedToDraftSucceeds(): void
    {
        $user = new User();
        $user->setEmail('archivedToDraft@example.com');
        $user->setPassword('test');
        $user->setRoles(['ROLE_ADMIN']);
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $entity = $this->em->find(Article::class, $this->entityId);
        $entity->setStatus('Archived');
        $this->em->flush();

        $this->client->request('PATCH', '/api/articles/' . $this->entityId . '/transitions/archived-to-draft');
        $this->assertResponseIsSuccessful();
        $data = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertEquals('Draft', $data['status'] ?? null);
    }

    public function testTransitionArchivedToDraftDeniedForWrongRole(): void
    {
        $user = new User();
        $user->setEmail('archivedToDraft.wrong@example.com');
        $user->setPassword('test');
        $this->em->persist($user);
        $this->em->flush();
        $this->client->loginUser($user);

        $this->client->request('PATCH', '/api/articles/' . $this->entityId . '/transitions/archived-to-draft');
        $this->assertResponseStatusCodeSame(403);
    }

    public function testTransitionPublishedToDraftIsDenied(): void
    {
        $this->client->request('PATCH', '/api/articles/' . $this->entityId . '/transitions/published-to-draft');
        $this->assertResponseStatusCodeSame(409);
    }
}
