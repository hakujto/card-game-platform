<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('card_price_histories', function (Blueprint $table) {
            $table->id();
            $table->date('price_date');
            $table->decimal('avg_price', 10, 2);
            $table->decimal('min_price', 10, 2);
            $table->decimal('max_price', 10, 2);
            $table->integer('volume');
            $table->boolean('foil')->default(false);
            $table->unsignedBigInteger('card_id');
            $table->foreign('card_id')->references('id')->on('cards')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('card_price_histories');
    }
};
