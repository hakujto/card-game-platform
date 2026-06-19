<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('draft_sessions', function (Blueprint $table) {
            $table->id();
            $table->string('status', 20)->default('WaitingForPlayers');
            $table->string('draft_type', 20)->default('Booster');
            $table->integer('seats')->default(8);
            $table->integer('time_per_pick_seconds')->default(30);
            $table->dateTime('completed_at')->nullable();
            $table->unsignedBigInteger('card_set_id');
            $table->foreign('card_set_id')->references('id')->on('card_sets')->restrictOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('draft_sessions');
    }
};
