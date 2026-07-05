<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('players', function (Blueprint $table) {
            $table->id();
            $table->uuid('public_id')->unique();
            $table->string('display_name', 50)->unique();
            $table->string('rank', 20)->default('Bronze');
            $table->integer('rating')->default(1000);
            $table->integer('peak_rating')->default(1000);
            $table->text('bio')->nullable();
            $table->string('country_code', 2)->nullable();
            $table->string('avatar_url', 200)->nullable();
            $table->string('preferred_format', 20)->nullable();
            $table->string('contact_email', 254)->nullable();
            $table->float('win_rate_cached')->nullable();
            $table->boolean('is_verified')->default(false);
            $table->dateTime('last_active_at')->nullable();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('players');
    }
};
