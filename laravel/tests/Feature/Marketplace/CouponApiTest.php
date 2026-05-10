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
            'discount_type' => 'test',
            'discount_value' => '0.00',
            'min_order_value' => '0.00',
            'uses_count' => 1,
            'valid_from' => '2024-01-01 00:00:00',
            'valid_until' => '2024-01-01 00:00:00',
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
            'discount_value' => '0.00',
            'min_order_value' => '0.00',
            'uses_count' => 1,
            'valid_from' => '2024-01-01 00:00:00',
            'valid_until' => '2024-01-01 00:00:00',
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
}
