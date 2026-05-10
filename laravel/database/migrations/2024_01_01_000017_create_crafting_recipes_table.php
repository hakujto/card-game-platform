<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('crafting_recipes', function (Blueprint $table) {
            $table->id();
            $table->integer('dust_cost');
            $table->boolean('is_available')->default(true);
            $table->unsignedBigInteger('result_card_id');
            $table->foreign('result_card_id')->references('id')->on('cards')->cascadeOnDelete();
            $table->timestamps();
        });

        Schema::create('crafting_recipe_required_cards_pivot', function (Blueprint $table) {
            $table->unsignedBigInteger('crafting_recipe_id');
            $table->unsignedBigInteger('card_id');
            $table->primary(['crafting_recipe_id', 'card_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('crafting_recipes');
    }
};
