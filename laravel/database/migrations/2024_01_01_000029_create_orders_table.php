<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('status', 20)->default('Pending');
            $table->decimal('total', 10, 2)->default('0');
            $table->decimal('discount_applied', 10, 2)->default('0');
            $table->string('currency', 3)->default('USD');
            $table->string('payment_method', 20)->nullable();
            $table->string('payment_reference', 200)->nullable();
            $table->text('shipping_address')->nullable();
            $table->string('tracking_number', 100)->nullable();
            $table->dateTime('paid_at')->nullable();
            $table->dateTime('shipped_at')->nullable();
            $table->unsignedBigInteger('player_id');
            $table->foreign('player_id')->references('id')->on('players')->cascadeOnDelete();
            $table->unsignedBigInteger('coupon_id')->nullable();
            $table->foreign('coupon_id')->references('id')->on('coupons')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
