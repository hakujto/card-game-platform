<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('card_sets', function (Blueprint $table) {
            $table->id();
            $table->string('name', 200);
            $table->string('code', 10);
            $table->date('release_date');
            $table->date('rotation_date')->nullable();
            $table->string('set_type', 20)->default('Expansion');
            $table->integer('total_cards');
            $table->boolean('is_rotated')->default(false);
            $table->text('description')->nullable();
            $table->string('logo_url', 200)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('card_sets');
    }
};
