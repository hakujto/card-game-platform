<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('articles', function (Blueprint $table) {
            $table->id();
            $table->string('title', 300);
            $table->string('slug', 300);
            $table->text('body');
            $table->text('excerpt')->nullable();
            $table->string('cover_image_url', 200)->nullable();
            $table->string('status', 20)->default('Draft');
            $table->string('article_type', 20)->default('Guide');
            $table->integer('view_count')->default(0);
            $table->dateTime('published_at')->nullable();
            $table->unsignedBigInteger('author_id');
            $table->foreign('author_id')->references('id')->on('players')->cascadeOnDelete();
            $table->unsignedBigInteger('featured_deck_id')->nullable();
            $table->foreign('featured_deck_id')->references('id')->on('decks')->nullOnDelete();
            $table->timestamps();
        });

        Schema::create('article_tags_pivot', function (Blueprint $table) {
            $table->unsignedBigInteger('article_id');
            $table->unsignedBigInteger('article_tag_id');
            $table->primary(['article_id', 'article_tag_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('articles');
    }
};
