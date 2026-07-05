<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('card_rulings', function (Blueprint $table) {
            $table->id();
            $table->text('ruling_text');
            $table->date('published_at');
            $table->string('source', 200);
            $table->unsignedBigInteger('card_id');
            $table->foreign('card_id')->references('id')->on('cards')->cascadeOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('card_rulings');
    }
};
