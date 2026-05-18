<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trade_transactions', function (Blueprint $table) {
            $table->id();
            $table->decimal('final_price', 10, 2);
            $table->decimal('platform_fee', 10, 2);
            $table->string('status', 20)->default('Pending');
            $table->dateTime('completed_at')->nullable();
            $table->unsignedBigInteger('listing_id');
            $table->foreign('listing_id')->references('id')->on('trade_listings')->cascadeOnDelete();
            $table->unsignedBigInteger('buyer_id');
            $table->foreign('buyer_id')->references('id')->on('players')->cascadeOnDelete();
            $table->unsignedBigInteger('seller_id');
            $table->foreign('seller_id')->references('id')->on('players')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trade_transactions');
    }
};
