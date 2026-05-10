<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('streams', function (Blueprint $table) {
            $table->id();
            $table->string('title', 300);
            $table->string('stream_url', 200);
            $table->string('platform', 20)->default('Twitch');
            $table->string('status', 20)->default('Scheduled');
            $table->integer('viewer_count_peak')->default(0);
            $table->dateTime('scheduled_start');
            $table->dateTime('actual_start')->nullable();
            $table->dateTime('ended_at')->nullable();
            $table->string('vod_url', 200)->nullable();
            $table->unsignedBigInteger('tournament_id')->nullable();
            $table->foreign('tournament_id')->references('id')->on('tournaments')->nullOnDelete();
            $table->unsignedBigInteger('streamer_id');
            $table->foreign('streamer_id')->references('id')->on('players')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('streams');
    }
};
