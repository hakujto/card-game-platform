<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('deck_tag_assignments', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('deck_id');
            $table->foreign('deck_id')->references('id')->on('decks')->cascadeOnDelete();
            $table->unsignedBigInteger('tag_id');
            $table->foreign('tag_id')->references('id')->on('deck_tags')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('deck_tag_assignments');
    }
};
