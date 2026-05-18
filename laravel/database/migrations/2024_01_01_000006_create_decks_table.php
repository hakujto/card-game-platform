<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('decks', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->string('format', 20)->default('Standard');
            $table->boolean('is_public')->default(false);
            $table->boolean('is_tournament_legal')->default(false);
            $table->string('archetype', 20)->nullable();
            $table->integer('wins')->default(0);
            $table->integer('losses')->default(0);
            $table->integer('draws')->default(0);
            $table->unsignedBigInteger('player_id');
            $table->foreign('player_id')->references('id')->on('players')->cascadeOnDelete();
            $table->timestamps();
        });

        Schema::create('deck_cards_pivot', function (Blueprint $table) {
            $table->unsignedBigInteger('deck_id');
            $table->unsignedBigInteger('card_id');
            $table->primary(['deck_id', 'card_id']);
        });
        Schema::create('deck_sideboard_cards_pivot', function (Blueprint $table) {
            $table->unsignedBigInteger('deck_id');
            $table->unsignedBigInteger('card_id');
            $table->primary(['deck_id', 'card_id']);
        });
        Schema::create('deck_tags_pivot', function (Blueprint $table) {
            $table->unsignedBigInteger('deck_id');
            $table->unsignedBigInteger('deck_tag_id');
            $table->primary(['deck_id', 'deck_tag_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('decks');
    }
};
