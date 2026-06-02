<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Review;

class ReviewSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Review::create([
            'place_id' => 1,
            'user_name' => 'Aerio',
            'rating' => 5,
            'comment' => 'Tempatnya nyaman dan WiFi cepat'
        ]);

        Review::create([
            'place_id' => 1,
            'user_name' => 'David',
            'rating' => 4,
            'comment' => 'Cocok buat nugas'
        ]);

        Review::create([
            'place_id' => 2,
            'user_name' => 'Budi',
            'rating' => 4,
            'comment' => 'Makanan murah'
        ]);
    }
}