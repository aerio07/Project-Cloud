<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Place;

class PlaceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Place::create([
            'category_id' => 1,
            'name' => 'Kafe Literasi',
            'address' => 'Jl. Kampus No. 1',
            'latitude' => -7.2575,
            'longitude' => 112.7521,
            'description' => 'Tempat nyaman untuk belajar dan nongkrong',
            'rating' => 4.5,
            'photo_url' => 'https://example.com/cafe.jpg',
            'opening_hours' => '08:00 - 22:00'
        ]);

        Place::create([
            'category_id' => 2,
            'name' => 'Kantin Teknik',
            'address' => 'Gedung Teknik Lt. 1',
            'latitude' => -7.2580,
            'longitude' => 112.7530,
            'description' => 'Kantin mahasiswa teknik',
            'rating' => 4.2,
            'photo_url' => 'https://example.com/kantin.jpg',
            'opening_hours' => '07:00 - 20:00'
        ]);

        Place::create([
            'category_id' => 3,
            'name' => 'ATM Center',
            'address' => 'Depan Perpustakaan',
            'latitude' => -7.2590,
            'longitude' => 112.7540,
            'description' => 'ATM berbagai bank',
            'rating' => 4.0,
            'photo_url' => 'https://example.com/atm.jpg',
            'opening_hours' => '24 Jam'
        ]);
    }
}