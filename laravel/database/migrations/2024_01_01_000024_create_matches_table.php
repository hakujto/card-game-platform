<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('matches', function (Blueprint $table) {
            $table->id();
            $table->integer('table_number')->nullable();
            $table->string('status', 20)->default('Pending');
            $table->integer('player1_wins')->default(0);
            $table->integer('player2_wins')->default(0);
            $table->dateTime('started_at')->nullable();
            $table->dateTime('ended_at')->nullable();
            $table->text('result_notes')->nullable();
            $table->unsignedBigInteger('round_id');
            $table->foreign('round_id')->references('id')->on('tournament_rounds')->cascadeOnDelete();
            $table->unsignedBigInteger('player1_id');
            $table->foreign('player1_id')->references('id')->on('players')->cascadeOnDelete();
            $table->unsignedBigInteger('player2_id')->nullable();
            $table->foreign('player2_id')->references('id')->on('players')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('matches');
    }
};
