<?php

namespace Tests\Feature\Content;

use App\Models\Content\DraftSession;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Cards\CardSet;

class DraftSessionApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private CardSet $depCardSet;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depCardSet = CardSet::create([
            'name' => 'test',
            'code' => 'test',
            'release_date' => '2024-01-01',
            'set_type' => 'Core',
            'total_cards' => 1,
        ]);
        $entity = DraftSession::create([
            'status' => 'WaitingForPlayers',
            'draft_type' => 'Booster',
            'seats' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'card_set_id' => $this->depCardSet->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/draft_sessions');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/draft_sessions', [
            'status' => 'WaitingForPlayers',
            'draft_type' => 'Booster',
            'seats' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'card_set_id' => $this->depCardSet->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/draft_sessions/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/draft_sessions/{$this->entityId}", [
            'seats' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/draft_sessions/{$this->entityId}");
        $response->assertStatus(204);
    }

}
