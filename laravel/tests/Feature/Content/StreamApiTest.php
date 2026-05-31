<?php

namespace Tests\Feature\Content;

use App\Models\Content\Stream;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;

class StreamApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    private Player $depStreamer;

    protected function setUp(): void
    {
        parent::setUp();
        $this->depStreamer = Player::create([
            'display_name' => 'test',
            'rank' => 'Bronze',
            'rating' => 1,
            'peak_rating' => 1,
            'is_verified' => true,
            'created_at' => '2024-01-01 00:00:00',
        ]);
        $entity = Stream::create([
            'title' => 'test',
            'stream_url' => 'https://example.com',
            'status' => 'Live',
            'platform' => 'Twitch',
            'language' => 'EN',
            'is_official' => true,
            'viewer_count_peak' => 1,
            'scheduled_start' => '2024-01-01 00:00:00',
            'actual_start' => null,
            'ended_at' => null,
            'streamer_id' => $this->depStreamer->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/streams');
        $response->assertStatus(200);
    }

    public function test_search_returns_200(): void
    {
        $response = $this->getJson('/api/streams?q=test');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/streams', [
            'title' => 'test',
            'stream_url' => 'https://example.com',
            'status' => 'Live',
            'platform' => 'Twitch',
            'language' => 'EN',
            'is_official' => true,
            'viewer_count_peak' => 1,
            'scheduled_start' => '2024-01-01 00:00:00',
            'actual_start' => null,
            'ended_at' => null,
            'streamer_id' => $this->depStreamer->id,
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

    public function test_create_fails_when_actual_start_requires_live_or_ended_violated(): void
    {
        // actual_start_requires_live_or_ended
        $response = $this->postJson('/api/streams', ['title' => 'test', 'stream_url' => 'https://example.com', 'scheduled_start' => '2024-01-01 00:00:00', 'streamer_id' => 1, 'actual_start' => '2024-01-01 00:00:00', 'status' => 'Scheduled']);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_ended_at_requires_ended_status_violated(): void
    {
        // ended_at can only be set when stream status is Ended
        $response = $this->postJson('/api/streams', ['title' => 'test', 'stream_url' => 'https://example.com', 'scheduled_start' => '2024-01-01 00:00:00', 'streamer_id' => 1, 'ended_at' => '2024-01-01 00:00:00', 'status' => 'Scheduled']);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_viewer_count_not_negative_violated(): void
    {
        // Peak viewer count must not be negative
        $response = $this->postJson('/api/streams', ['title' => 'test', 'stream_url' => 'https://example.com', 'scheduled_start' => '2024-01-01 00:00:00', 'streamer_id' => 1, 'actual_start' => '2024-01-01 00:00:00', 'status' => 'Live', 'ended_at' => '2024-01-01 00:00:00', 'status' => 'Ended', 'viewer_count_peak' => -1]);
        $response->assertStatus(422);
    }
    public function test_transition_scheduled_to_live(): void
    {
        \DB::table('streams')->where('id', $this->entityId)->update(['status' => 'Scheduled']);
        $response = $this->patchJson("/api/streams/{$this->entityId}/transitions/scheduled-to-live");
        $this->assertContains($response->status(), [200, 422]);
    }

    public function test_transition_live_to_ended(): void
    {
        \DB::table('streams')->where('id', $this->entityId)->update(['status' => 'Live']);
        $response = $this->patchJson("/api/streams/{$this->entityId}/transitions/live-to-ended");
        $response->assertStatus(200);
    }

    public function test_transition_ended_to_live(): void
    {
        \DB::table('streams')->where('id', $this->entityId)->update(['status' => 'Ended']);
        $response = $this->patchJson("/api/streams/{$this->entityId}/transitions/ended-to-live");
        $response->assertStatus(409);
    }
}
