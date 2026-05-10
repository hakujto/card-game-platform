<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('deck_sideboard_cards', function (Blueprint $table) {
            $table->id();
            $table->integer('quantity')->default(1);
            $table->unsignedBigInteger('deck_id');
            $table->foreign('deck_id')->references('id')->on('decks')->cascadeOnDelete();
            $table->unsignedBigInteger('card_id');
            $table->foreign('card_id')->references('id')->on('cards')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('deck_sideboard_cards');
    }
};
