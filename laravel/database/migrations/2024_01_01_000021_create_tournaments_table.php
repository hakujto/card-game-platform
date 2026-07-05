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
            $table->uuid('public_id')->unique();
            $table->string('name', 200);
            $table->text('description')->nullable();
            $table->string('status', 20)->default('Draft');
            $table->json('bracket_data')->nullable();
            $table->string('format', 20)->default('Standard');
            $table->string('tournament_type', 20)->default('Swiss');
            $table->integer('max_players');
            $table->decimal('entry_fee', 10, 2)->default('0');
            $table->decimal('prize_pool', 10, 2)->default('0');
            $table->dateTime('start_time');
            $table->dateTime('end_time')->nullable();
            $table->boolean('is_online')->default(true);
            $table->string('location', 300)->nullable();
            $table->text('rules_text')->nullable();
            $table->unsignedBigInteger('season_id');
            $table->foreign('season_id')->references('id')->on('seasons')->restrictOnDelete();
            $table->unsignedBigInteger('organizer_id');
            $table->foreign('organizer_id')->references('id')->on('players')->restrictOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tournaments');
    }
};
