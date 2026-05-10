<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('player_collections', function (Blueprint $table) {
            $table->id();
            $table->integer('quantity')->default(1);
            $table->boolean('foil')->default(false);
            $table->string('condition', 20)->default('Mint');
            $table->dateTime('acquired_at');
            $table->string('acquired_via', 20)->default('Purchase');
            $table->unsignedBigInteger('player_id');
            $table->foreign('player_id')->references('id')->on('players')->cascadeOnDelete();
            $table->unsignedBigInteger('card_id');
            $table->foreign('card_id')->references('id')->on('cards')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('player_collections');
    }
};
