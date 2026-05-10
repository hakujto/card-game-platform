<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('trade_disputes', function (Blueprint $table) {
            $table->id();
            $table->string('reason', 20);
            $table->text('description');
            $table->string('status', 20)->default('Open');
            $table->text('resolution')->nullable();
            $table->dateTime('opened_at');
            $table->dateTime('resolved_at')->nullable();
            $table->unsignedBigInteger('transaction_id');
            $table->foreign('transaction_id')->references('id')->on('trade_transactions')->cascadeOnDelete();
            $table->unsignedBigInteger('opened_by_id');
            $table->foreign('opened_by_id')->references('id')->on('players')->cascadeOnDelete();
            $table->unsignedBigInteger('resolved_by_id')->nullable();
            $table->foreign('resolved_by_id')->references('id')->on('players')->nullOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('trade_disputes');
    }
};
