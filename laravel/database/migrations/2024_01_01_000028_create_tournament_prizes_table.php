<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tournament_prizes', function (Blueprint $table) {
            $table->id();
            $table->integer('placement_from');
            $table->integer('placement_to');
            $table->string('prize_type', 20);
            $table->decimal('amount', 10, 2)->default('0');
            $table->text('description')->nullable();
            $table->integer('packs_count')->nullable();
            $table->integer('season_points')->default(0);
            $table->unsignedBigInteger('tournament_id');
            $table->foreign('tournament_id')->references('id')->on('tournaments')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tournament_prizes');
    }
};
