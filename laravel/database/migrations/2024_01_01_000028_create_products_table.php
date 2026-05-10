<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name', 200);
            $table->string('product_type', 20)->default('SingleCard');
            $table->decimal('price', 10, 2);
            $table->integer('stock')->default(0);
            $table->boolean('active')->default(true);
            $table->integer('discount_percent')->default(0);
            $table->text('description')->nullable();
            $table->string('image_url', 200)->nullable();
            $table->boolean('featured')->default(false);
            $table->unsignedBigInteger('card_id')->nullable();
            $table->foreign('card_id')->references('id')->on('cards')->nullOnDelete();
            $table->unsignedBigInteger('card_set_id')->nullable();
            $table->foreign('card_set_id')->references('id')->on('card_sets')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
