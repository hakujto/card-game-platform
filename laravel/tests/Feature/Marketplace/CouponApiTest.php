<?php

namespace Tests\Feature\Marketplace;

use App\Models\Marketplace\Coupon;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CouponApiTest extends TestCase
{
    use RefreshDatabase;

    private int $entityId;

    protected function setUp(): void
    {
        parent::setUp();
        $entity = Coupon::create([
            'code' => 'test',
            'discount_type' => 'Percent',
            'discount_value' => '1.00',
            'min_order_value' => '0.00',
            'max_uses' => null,
            'uses_count' => 1,
            'valid_from' => '2024-01-01 00:00:00',
            'valid_until' => '2024-01-01 00:00:01',
            'is_active' => true,
        ]);
        $this->entityId = $entity->id;
    }

    public function test_list_returns_200(): void
    {
        $response = $this->getJson('/api/coupons');
        $response->assertStatus(200);
    }

    public function test_create_returns_201(): void
    {
        $response = $this->postJson('/api/coupons', [
            'code' => 'test',
            'discount_type' => 'Percent',
            'discount_value' => '1.00',
            'min_order_value' => '0.00',
            'max_uses' => null,
            'uses_count' => 1,
            'valid_from' => '2024-01-01 00:00:00',
            'valid_until' => '2024-01-01 00:00:01',
            'is_active' => true,
        ]);
        $response->assertStatus(201);
    }

    public function test_show_returns_200(): void
    {
        $response = $this->getJson("/api/coupons/{$this->entityId}");
        $response->assertStatus(200);
    }

    public function test_update_returns_200(): void
    {
        $response = $this->patchJson("/api/coupons/{$this->entityId}", [
            'code' => 'test',
        ]);
        $response->assertStatus(200);
    }

    public function test_delete_returns_204(): void
    {
        $response = $this->deleteJson("/api/coupons/{$this->entityId}");
        $response->assertStatus(204);
    }

    public function test_create_fails_when_valid_until_after_valid_from_violated(): void
    {
        // Coupon expiry must be after its start date
        $response = $this->postJson('/api/coupons', ['code' => 'test', 'valid_from' => '2024-01-01 00:00:00', 'discount_type' => 'Percent', 'discount_value' => 1, 'max_uses' => 1, 'valid_until' => '2024-01-01 00:00:00']);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_discount_value_positive_violated(): void
    {
        // Discount value must be greater than zero
        $response = $this->postJson('/api/coupons', ['code' => 'test', 'valid_from' => '2024-01-01 00:00:00', 'valid_until' => '2024-01-01 00:00:00', 'discount_type' => 'Percent', 'max_uses' => 1, 'discount_value' => 0]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_percent_discount_range_violated(): void
    {
        // Percent discount must be between 1 and 100
        $response = $this->postJson('/api/coupons', ['code' => 'test', 'valid_from' => '2024-01-01 00:00:00', 'valid_until' => '2024-01-01 00:00:00', 'discount_type' => 'Percent', 'discount_value' => 101]);
        $response->assertStatus(422);
    }

    public function test_create_fails_when_uses_not_exceed_max_violated(): void
    {
        // Coupon uses count cannot exceed max_uses
        $response = $this->postJson('/api/coupons', ['code' => 'test', 'discount_value' => '0.00', 'valid_from' => '2024-01-01 00:00:00', 'valid_until' => '2024-01-01 00:00:00', 'max_uses' => 1]);
        $response->assertStatus(422);
    }
}
