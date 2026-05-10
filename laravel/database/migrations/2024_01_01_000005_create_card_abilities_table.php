<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('card_abilities', function (Blueprint $table) {
            $table->id();
            $table->string('ability_type', 20)->default('Keyword');
            $table->string('keyword', 100)->nullable();
            $table->text('ability_text');
            $table->string('timing', 20)->nullable();
            $table->unsignedBigInteger('card_id');
            $table->foreign('card_id')->references('id')->on('cards')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('card_abilities');
    }
};
