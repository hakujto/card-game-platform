<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('games', function (Blueprint $table) {
            $table->id();
            $table->integer('game_number');
            $table->string('winner_side', 20)->nullable();
            $table->integer('turns_played')->nullable();
            $table->integer('duration_seconds')->nullable();
            $table->string('ended_by', 20)->nullable();
            $table->string('replay_url', 200)->nullable();
            $table->unsignedBigInteger('match_id');
            $table->foreign('match_id')->references('id')->on('matches')->cascadeOnDelete();
            $table->unsignedBigInteger('winner_id')->nullable();
            $table->foreign('winner_id')->references('id')->on('players')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('games');
    }
};
