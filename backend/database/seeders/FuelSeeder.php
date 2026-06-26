<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Fuel;
use App\Models\Place;

class FuelSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Create Fuels
        $pertalite = Fuel::create([
            'id' => 1,
            'name' => 'Pertalite',
            'octane' => '90',
            'national_price' => 10000.00,
        ]);

        $pertamax = Fuel::create([
            'id' => 2,
            'name' => 'Pertamax',
            'octane' => '92',
            'national_price' => 12950.00,
        ]);

        $turbo = Fuel::create([
            'id' => 3,
            'name' => 'Pertamax Turbo',
            'octane' => '98',
            'national_price' => 14400.00,
        ]);

        $dexlite = Fuel::create([
            'id' => 4,
            'name' => 'Dexlite',
            'octane' => 'D', // CN 51
            'national_price' => 14550.00,
        ]);

        $dex = Fuel::create([
            'id' => 5,
            'name' => 'Pertamina Dex',
            'octane' => 'D+', // CN 53
            'national_price' => 15100.00,
        ]);

        // 2. Attach to Places (SPBU)
        // Place 1: SPBU COCO Dr. Soetomo (Semua Bahan Bakar)
        $place1 = Place::find(1);
        if ($place1) {
            $place1->fuels()->attach([
                $pertalite->id => ['is_available' => true, 'price' => 10000.00],
                $pertamax->id => ['is_available' => true, 'price' => 12950.00],
                $turbo->id => ['is_available' => true, 'price' => 14400.00],
                $dexlite->id => ['is_available' => true, 'price' => 14550.00],
                $dex->id => ['is_available' => true, 'price' => 15100.00],
            ]);
        }

        // Place 2: SPBU COCO MERR Kalijudan (Semua Bahan Bakar)
        $place2 = Place::find(2);
        if ($place2) {
            $place2->fuels()->attach([
                $pertalite->id => ['is_available' => true, 'price' => 10000.00],
                $pertamax->id => ['is_available' => true, 'price' => 12950.00],
                $turbo->id => ['is_available' => true, 'price' => 14400.00],
                $dexlite->id => ['is_available' => true, 'price' => 14550.00],
                $dex->id => ['is_available' => true, 'price' => 15100.00],
            ]);
        }

        // Place 3: SPBU Jemursari (Bensin & Diesel Reguler, tanpa Turbo)
        $place3 = Place::find(3);
        if ($place3) {
            $place3->fuels()->attach([
                $pertalite->id => ['is_available' => true, 'price' => 10000.00],
                $pertamax->id => ['is_available' => true, 'price' => 12950.00],
                $dexlite->id => ['is_available' => true, 'price' => 14550.00],
                $dex->id => ['is_available' => true, 'price' => 15100.00],
            ]);
        }

        // Place 4: Pertashop Kenjeran (Hanya Pertamax)
        $place4 = Place::find(4);
        if ($place4) {
            $place4->fuels()->attach([
                $pertamax->id => ['is_available' => true, 'price' => 12950.00],
            ]);
        }
    }
}
