<?php

namespace Tests\Feature\Content;

use App\Models\Content\DraftParticipant;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DraftParticipantApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = DraftParticipant::create([
            'seat_number' => 1,
            'joined_at' => '2024-01-01 00:00:00',
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/draft_participants');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/draft_participants', [
            'seat_number' => 1,
            'joined_at' => '2024-01-01 00:00:00',
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/draft_participants/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/draft_participants/{$this->entityId}", [
            'seat_number' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/draft_participants/{$this->entityId}");
        $response->assertStatus(204);
    }
}
