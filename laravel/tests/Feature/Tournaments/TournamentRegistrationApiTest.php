<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\TournamentRegistration;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TournamentRegistrationApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = TournamentRegistration::create([
            'status' => 'test',
            'points_earned' => 1,
            'registered_at' => '2024-01-01 00:00:00',
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/tournament_registrations');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/tournament_registrations', [
            'points_earned' => 1,
            'registered_at' => '2024-01-01 00:00:00',
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/tournament_registrations/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/tournament_registrations/{$this->entityId}", [
            'status' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/tournament_registrations/{$this->entityId}");
        $response->assertStatus(204);
    }
}
