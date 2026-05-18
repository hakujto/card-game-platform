<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trade_bids', function (Blueprint $table) {
            $table->id();
            $table->decimal('amount', 10, 2);
            $table->dateTime('placed_at');
            $table->boolean('is_winning')->default(false);
            $table->unsignedBigInteger('listing_id');
            $table->foreign('listing_id')->references('id')->on('trade_listings')->cascadeOnDelete();
            $table->unsignedBigInteger('bidder_id');
            $table->foreign('bidder_id')->references('id')->on('players')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trade_bids');
    }
};
