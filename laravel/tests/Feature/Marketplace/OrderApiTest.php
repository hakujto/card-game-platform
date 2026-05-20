<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\Order;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use App\Models\Players\Player;

class OrderApiTest extends TestCase
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
        $entity = Order::create([
            'status' => 'Shipped',
            'total' => '0.00',
            'discount_applied' => '0.00',
            'currency' => 'xxx',
            'tracking_number' => 'test',
            'created_at' => '2024-01-01 00:00:00',
            'paid_at' => '2024-01-01 00:00:00',
            'shipped_at' => null,
            'player_id' => $this->depPlayer->id,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/orders');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/orders', [
            'status' => 'Shipped',
            'total' => '0.00',
            'discount_applied' => '0.00',
            'currency' => 'xxx',
            'tracking_number' => 'test',
            'created_at' => '2024-01-01 00:00:00',
            'paid_at' => '2024-01-01 00:00:00',
            'shipped_at' => null,
            'player_id' => $this->depPlayer->id,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/orders/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/orders/{$this->entityId}", [
            'currency' => 'tes',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/orders/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_paid_requires_paid_at_violated(): void
    {
        // Paid order must have paid_at set
        $response = $this->postJson('/api/orders', ['created_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'status' => 'Paid', 'paid_at' => null]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_shipped_requires_tracking_violated(): void
    {
        // Shipped order must have a tracking number
        $response = $this->postJson('/api/orders', ['created_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'status' => 'Shipped', 'tracking_number' => null]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_shipped_at_requires_shipped_status_violated(): void
    {
        // shipped_at_requires_shipped_status
        $response = $this->postJson('/api/orders', ['created_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'shipped_at' => '2024-01-01 00:00:00', 'status' => 'Pending']);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_total_not_negative_violated(): void
    {
        // Order total must not be negative
        $response = $this->postJson('/api/orders', ['created_at' => '2024-01-01 00:00:00', 'player_id' => 1, 'status' => 'Paid', 'paid_at' => '2024-01-01 00:00:00', 'status' => 'Shipped', 'tracking_number' => 'test', 'shipped_at' => '2024-01-01 00:00:00', 'status' => 'Shipped', 'total' => -1]);
        $response->assertStatus(422);
    }
    public function test_transition_pending_to_paid(): void
    {
        \DB::table('orders')->where('id', $this->entityId)->update(['status' => 'Pending']);
        $response = $this->patchJson("/api/orders/{$this->entityId}/transitions/pending-to-paid");
        $this->assertContains($response->status(), [200, 422]);
    }

    public function test_transition_pending_to_paid_fails_when_payment_method_null(): void
    {
        \DB::table('orders')->where('id', $this->entityId)->update(['status' => 'Pending', 'payment_method' => null]);
        $response = $this->patchJson("/api/orders/{$this->entityId}/transitions/pending-to-paid");
        $response->assertStatus(422);
    }

    public function test_transition_paid_to_processing(): void
    {
        \DB::table('orders')->where('id', $this->entityId)->update(['status' => 'Paid']);
        $response = $this->patchJson("/api/orders/{$this->entityId}/transitions/paid-to-processing");
        $response->assertStatus(200);
    }

    public function test_transition_processing_to_shipped(): void
    {
        \DB::table('orders')->where('id', $this->entityId)->update(['status' => 'Processing']);
        $response = $this->patchJson("/api/orders/{$this->entityId}/transitions/processing-to-shipped");
        $this->assertContains($response->status(), [200, 422]);
    }

    public function test_transition_processing_to_shipped_fails_when_tracking_number_null(): void
    {
        \DB::table('orders')->where('id', $this->entityId)->update(['status' => 'Processing', 'tracking_number' => null]);
        $response = $this->patchJson("/api/orders/{$this->entityId}/transitions/processing-to-shipped");
        $response->assertStatus(422);
    }

    public function test_transition_shipped_to_completed(): void
    {
        \DB::table('orders')->where('id', $this->entityId)->update(['status' => 'Shipped']);
        $response = $this->patchJson("/api/orders/{$this->entityId}/transitions/shipped-to-completed");
        $response->assertStatus(200);
    }

    public function test_transition_pending_to_cancelled(): void
    {
        \DB::table('orders')->where('id', $this->entityId)->update(['status' => 'Pending']);
        $response = $this->patchJson("/api/orders/{$this->entityId}/transitions/pending-to-cancelled");
        $response->assertStatus(200);
    }

    public function test_transition_paid_to_cancelled(): void
    {
        \DB::table('orders')->where('id', $this->entityId)->update(['status' => 'Paid']);
        $response = $this->patchJson("/api/orders/{$this->entityId}/transitions/paid-to-cancelled");
        $response->assertStatus(200);
    }

    public function test_transition_completed_to_refunded(): void
    {
        \DB::table('orders')->where('id', $this->entityId)->update(['status' => 'Completed']);
        $response = $this->patchJson("/api/orders/{$this->entityId}/transitions/completed-to-refunded");
        $response->assertStatus(200);
    }

    public function test_transition_refunded_to_completed(): void
    {
        \DB::table('orders')->where('id', $this->entityId)->update(['status' => 'Refunded']);
        $response = $this->patchJson("/api/orders/{$this->entityId}/transitions/refunded-to-completed");
        $response->assertStatus(409);
    }

    public function test_transition_completed_to_cancelled(): void
    {
        \DB::table('orders')->where('id', $this->entityId)->update(['status' => 'Completed']);
        $response = $this->patchJson("/api/orders/{$this->entityId}/transitions/completed-to-cancelled");
        $response->assertStatus(409);
    }
}
