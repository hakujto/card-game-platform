<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cards', function (Blueprint $table) {
            $table->id();
            $table->string('name', 200);
            $table->string('card_type', 20)->default('Creature');
            $table->string('rarity', 20)->default('Common');
            $table->integer('mana_cost')->default(0);
            $table->string('mana_colors', 20);
            $table->integer('attack')->nullable();
            $table->integer('defense')->nullable();
            $table->integer('loyalty')->nullable();
            $table->text('description');
            $table->text('flavor_text')->nullable();
            $table->string('image_url', 200)->nullable();
            $table->string('artist_name', 100)->nullable();
            $table->string('legal_formats', 20);
            $table->boolean('is_banned')->default(false);
            $table->boolean('is_restricted')->default(false);
            $table->integer('power_level')->default(1);
            $table->unsignedBigInteger('set_id');
            $table->foreign('set_id')->references('id')->on('card_sets')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cards');
    }
};
