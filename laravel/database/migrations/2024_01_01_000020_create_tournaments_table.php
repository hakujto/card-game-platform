<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tournaments', function (Blueprint $table) {
            $table->id();
            $table->string('name', 200);
            $table->text('description')->nullable();
            $table->string('format', 20)->default('Standard');
            $table->string('tournament_type', 20)->default('Swiss');
            $table->string('status', 20)->default('Draft');
            $table->integer('max_players');
            $table->decimal('entry_fee', 10, 2)->default('0');
            $table->decimal('prize_pool', 10, 2)->default('0');
            $table->dateTime('start_time');
            $table->dateTime('end_time')->nullable();
            $table->boolean('is_online')->default(true);
            $table->string('location', 300)->nullable();
            $table->text('rules_text')->nullable();
            $table->unsignedBigInteger('season_id');
            $table->foreign('season_id')->references('id')->on('seasons')->cascadeOnDelete();
            $table->unsignedBigInteger('organizer_id');
            $table->foreign('organizer_id')->references('id')->on('players')->cascadeOnDelete();
            $table->timestamps();
        });

        Schema::create('tournament_judges_pivot', function (Blueprint $table) {
            $table->unsignedBigInteger('tournament_id');
            $table->unsignedBigInteger('player_id');
            $table->primary(['tournament_id', 'player_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tournaments');
    }
};
