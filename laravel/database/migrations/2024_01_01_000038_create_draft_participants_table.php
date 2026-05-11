<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('draft_participants', function (Blueprint $table) {
            $table->id();
            $table->integer('seat_number');
            $table->dateTime('joined_at');
            $table->unsignedBigInteger('session_id');
            $table->foreign('session_id')->references('id')->on('draft_sessions')->cascadeOnDelete();
            $table->unsignedBigInteger('player_id');
            $table->foreign('player_id')->references('id')->on('players')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('draft_participants');
    }
};
