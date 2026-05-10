<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('draft_picks', function (Blueprint $table) {
            $table->id();
            $table->integer('pick_number');
            $table->integer('pack_number');
            $table->dateTime('picked_at');
            $table->unsignedBigInteger('participant_id');
            $table->foreign('participant_id')->references('id')->on('draft_participants')->cascadeOnDelete();
            $table->unsignedBigInteger('card_id');
            $table->foreign('card_id')->references('id')->on('cards')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('draft_picks');
    }
};
