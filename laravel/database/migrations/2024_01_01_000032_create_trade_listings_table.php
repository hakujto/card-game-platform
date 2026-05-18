<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trade_listings', function (Blueprint $table) {
            $table->id();
            $table->string('listing_type', 20)->default('FixedPrice');
            $table->decimal('asking_price', 10, 2)->nullable();
            $table->decimal('auction_start_price', 10, 2)->nullable();
            $table->decimal('auction_current_bid', 10, 2)->nullable();
            $table->dateTime('auction_end_time')->nullable();
            $table->boolean('foil')->default(false);
            $table->string('condition', 20)->default('Mint');
            $table->integer('quantity')->default(1);
            $table->string('status', 20)->default('Active');
            $table->text('description')->nullable();
            $table->dateTime('expires_at')->nullable();
            $table->unsignedBigInteger('seller_id');
            $table->foreign('seller_id')->references('id')->on('players')->cascadeOnDelete();
            $table->unsignedBigInteger('card_id');
            $table->foreign('card_id')->references('id')->on('cards')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trade_listings');
    }
};
