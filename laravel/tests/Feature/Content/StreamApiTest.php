<?php

namespace Tests\Feature\Content;

use App\Models\Content\Stream;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StreamApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = Stream::create([
            'title' => 'test',
            'stream_url' => 'https://example.com',
            'platform' => 'test',
            'status' => 'test',
            'viewer_count_peak' => 1,
            'scheduled_start' => '2024-01-01 00:00:00',
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/streams');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/streams', [
            'title' => 'test',
            'stream_url' => 'https://example.com',
            'viewer_count_peak' => 1,
            'scheduled_start' => '2024-01-01 00:00:00',
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/streams/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/streams/{$this->entityId}", [
            'title' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/streams/{$this->entityId}");
        $response->assertStatus(204);
    }
}
