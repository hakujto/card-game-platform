<?php

namespace Tests\Feature\Tournaments;

use App\Models\Tournaments\AwardedPrize;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Tournaments\Season;
use App\Models\Players\Player;
use App\Models\Tournaments\Tournament;
use App\Models\Tournaments\TournamentPrize;

class AwardedPrizeApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Season $auxSeason;
    private Player $auxPlayer;
    private Tournament $auxTournament;
    private TournamentPrize $depPrize;
    private Player $depPlayer;

    protected function setUp(): void
    {
        parent::setUp();
        $this->auxSeason = Season::create([
            'name' => 'test',
            'start_date' => '2024-01-01',
            'end_date' => '2024-01-01',
            'format' => 'Standard',
            'is_active' => true,
        ]);
        $this->auxPlayer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $this->auxTournament = Tournament::create([
            'name' => 'test',
            'format' => 'Standard',
            'tournament_type' => 'Swiss',
            'status' => 'Draft',
            'max_players' => 1,
            'entry_fee' => '0.00',
            'prize_pool' => '0.00',
            'start_time' => '2024-01-01 00:00:00',
            'is_online' => true,
            'created_at' => '2024-01-01 00:00:00',
            'season_id' => $this->auxSeason->id,
            'organizer_id' => $this->auxPlayer->id,
        ]);
        $this->depPrize = TournamentPrize::create([
            'placement_from' => 1,
            'placement_to' => 1,
            'prize_type' => 'Currency',
            'amount' => '0.00',
            'season_points' => 1,
            'tournament_id' => $this->auxTournament->id,
        ]);
        $this->depPlayer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = AwardedPrize::create([
            'final_placement' => 1,
            'awarded_at' => '2024-01-01 00:00:00',
            'claimed' => true,
            'claimed_at' => '2024-01-01 00:00:00',
            'prize_id' => $this->depPrize->id,
            'player_id' => $this->depPlayer->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/awarded_prizes');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/awarded_prizes', [
            'final_placement' => 1,
            'awarded_at' => '2024-01-01 00:00:00',
            'claimed' => true,
            'claimed_at' => '2024-01-01 00:00:00',
            'prize_id' => $this->depPrize->id,
            'player_id' => $this->depPlayer->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/awarded_prizes/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/awarded_prizes/{$this->entityId}", [
            'final_placement' => 1,
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/awarded_prizes/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_claimed_requires_claimed_at_violated(): void
    {
        // Claimed prize must have a claimed_at timestamp
        $response = $this->postJson('/api/awarded_prizes', ['final_placement' => 1, 'awarded_at' => '2024-01-01 00:00:00', 'prize_id' => 1, 'player_id' => 1, 'claimed' => true, 'claimed_at' => null]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_final_placement_positive_violated(): void
    {
        // Final placement must be greater than zero
        $response = $this->postJson('/api/awarded_prizes', ['awarded_at' => '2024-01-01 00:00:00', 'prize_id' => 1, 'player_id' => 1, 'claimed' => true, 'claimed_at' => '2024-01-01 00:00:00', 'final_placement' => 0]);
        $response->assertStatus(422);
    }
}
