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
        Schema::create('place_fuel', function (Blueprint $table) {
    $table->id();
    $table->foreignId('place_id')->constrained()->cascadeOnDelete();
    $table->foreignId('fuel_id')->constrained()->cascadeOnDelete();
    $table->boolean('is_available')->default(true);
    $table->decimal('price', 12, 2)->nullable();
    $table->timestamps();

    $table->unique(['place_id', 'fuel_id']);
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('place_fuel');
    }
};
