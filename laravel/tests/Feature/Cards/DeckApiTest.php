<?php

namespace Tests\Feature\Cards;

use App\Models\Cards\Deck;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;

class DeckApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $depPlayer;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depPlayer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = Deck::create([
            'name' => 'test',
            'format' => 'Standard',
            'is_public' => true,
            'is_tournament_legal' => false,
            'wins' => 1,
            'losses' => 1,
            'draws' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'updated_at' => '2024-01-01 00:00:00',
            'player_id' => $this->depPlayer->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/decks');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/decks', [
            'name' => 'test',
            'format' => 'Standard',
            'is_public' => true,
            'is_tournament_legal' => false,
            'wins' => 1,
            'losses' => 1,
            'draws' => 1,
            'created_at' => '2024-01-01 00:00:00',
            'updated_at' => '2024-01-01 00:00:00',
            'player_id' => $this->depPlayer->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/decks/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/decks/{$this->entityId}", [
            'name' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/decks/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_wins_not_negative_violated(): void
    {
        // Deck wins count must not be negative
        $response = $this->postJson('/api/decks', ['name' => 'test', 'created_at' => '2024-01-01 00:00:00', 'updated_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'is_tournament_legal' => true, 'is_public' => true, 'wins' => -1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_losses_not_negative_violated(): void
    {
        // Deck losses count must not be negative
        $response = $this->postJson('/api/decks', ['name' => 'test', 'created_at' => '2024-01-01 00:00:00', 'updated_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'is_tournament_legal' => true, 'is_public' => true, 'losses' => -1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_draws_not_negative_violated(): void
    {
        // Deck draws count must not be negative
        $response = $this->postJson('/api/decks', ['name' => 'test', 'created_at' => '2024-01-01 00:00:00', 'updated_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'is_tournament_legal' => true, 'is_public' => true, 'draws' => -1]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_tournament_legal_deck_must_be_validated_violated(): void
    {
        // Tournament-legal deck must be made public
        $response = $this->postJson('/api/decks', ['name' => 'test', 'created_at' => '2024-01-01 00:00:00', 'updated_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'is_tournament_legal' => true, 'is_public' => false]);
        $response->assertStatus(422);
    }
}
