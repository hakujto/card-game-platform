<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('awarded_prizes', function (Blueprint $table) {
            $table->id();
            $table->integer('final_placement');
            $table->dateTime('awarded_at');
            $table->boolean('claimed')->default(false);
            $table->dateTime('claimed_at')->nullable();
            $table->unsignedBigInteger('prize_id');
            $table->foreign('prize_id')->references('id')->on('tournament_prizes')->cascadeOnDelete();
            $table->unsignedBigInteger('player_id');
            $table->foreign('player_id')->references('id')->on('players')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('awarded_prizes');
    }
};
