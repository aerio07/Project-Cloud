<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('places', function (Blueprint $table) {
            $table->id();

            $table->foreignId('category_id')
                  ->constrained()
                  ->onDelete('cascade');

            $table->string('name');

            $table->text('address');

            $table->double('latitude');
            $table->double('longitude');

            $table->text('description')->nullable();

            $table->double('rating')->default(0);

            $table->text('photo_url')->nullable();

            $table->string('opening_hours')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('places');
    }
};