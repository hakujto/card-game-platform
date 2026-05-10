<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\TournamentJudge;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TournamentJudgeApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = TournamentJudge::create([
            'role' => 'test',
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/tournament_judges');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/tournament_judges', [

        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/tournament_judges/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/tournament_judges/{$this->entityId}", [
            'role' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/tournament_judges/{$this->entityId}");
        $response->assertStatus(204);
    }
}
