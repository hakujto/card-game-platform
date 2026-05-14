<?php

namespace App\Tests\Content;

use App\Entity\Content\Stream;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Players\Player;

class StreamApiTest extends WebTestCase
{
    private \Symfony\Bundle\FrameworkBundle\KernelBrowser $client;
    private EntityManagerInterface $em;
    private int $entityId;
    private Player $depStreamer;

    protected function setUp(): void
    {
        $this->client = static::createClient();
        $this->em = static::getContainer()->get(EntityManagerInterface::class);

        $this->depStreamer = new Player();
        $this->em->persist($this->depStreamer);

        $entity = new Stream();
        $entity->setTitle('test');
        $entity->setStreamUrl('https://example.com');
        $entity->setScheduledStart(new \DateTime('2024-01-01'));
        $entity->setStreamer($this->depStreamer);
        $this->em->persist($entity);
        $this->em->flush();

        $this->entityId = (int) $entity->getId();
    }

    public function testListReturns200(): void
    {
        $this->client->request('GET', '/api/streams');
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testCreateReturns201(): void
    {
        $this->client->request('POST', '/api/streams', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode([
            'title' => 'test',
            'streamUrl' => 'https://example.com',
            'scheduledStart' => '2024-01-01T00:00:00+00:00',
            'streamer' => (int) $this->depStreamer->getId(),
        ])
        );
        $this->assertResponseStatusCodeSame(201);
    }

    public function testShowReturns200(): void
    {
        $this->client->request('GET', '/api/streams/' . $this->entityId);
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testUpdateReturns200(): void
    {
        $this->client->request('PATCH', '/api/streams/' . $this->entityId, [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['title' => 'test'])
        );
        $this->assertResponseIsSuccessful();
        $this->assertResponseStatusCodeSame(200);
    }

    public function testDeleteReturns204(): void
    {
        $this->client->request('DELETE', '/api/streams/' . $this->entityId);
        $this->assertResponseStatusCodeSame(204);
    }

    public function testCreateFailsWhenActualStartRequiresLiveOrEndedViolated(): void
    {
        // actual_start_requires_live_or_ended
        $this->client->request('POST', '/api/streams', [], [], ['CONTENT_TYPE' => 'application/json'],
            json_encode(['title' => 'test', 'streamUrl' => 'https://example.com', 'platform' => 'TWITCH', 'status' => 'SCHEDULED', 'viewerCountPeak' => 1, 'scheduledStart' => '2024-01-01T00:00:00+00:00', 'actualStart' => '2024-01-01T00:00:00+00:00'])
        );
        $this->assertResponseStatusCodeSame(422);
    }
}
