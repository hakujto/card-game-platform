<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('crafting_ingredients', function (Blueprint $table) {
            $table->id();
            $table->integer('quantity')->default(1);
            $table->unsignedBigInteger('recipe_id');
            $table->foreign('recipe_id')->references('id')->on('crafting_recipes')->cascadeOnDelete();
            $table->unsignedBigInteger('card_id');
            $table->foreign('card_id')->references('id')->on('cards')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('crafting_ingredients');
    }
};
