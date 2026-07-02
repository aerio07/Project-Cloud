<?php

namespace Database\Seeders;

use App\Models\Fuel;
use App\Models\Place;
use Illuminate\Database\Seeder;

class FuelSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // ============================================================
        // 1. Master Fuel Harga Nasional
        // ============================================================
        $pertalite = Fuel::create([
            'id' => 1,
            'brand' => 'Pertamina',
            'name' => 'Pertalite',
            'octane' => '90',
            'national_price' => 10000.00,
        ]);

        $pertamax = Fuel::create([
            'id' => 2,
            'brand' => 'Pertamina',
            'name' => 'Pertamax',
            'octane' => '92',
            'national_price' => 12950.00,
        ]);

        $turbo = Fuel::create([
            'id' => 3,
            'brand' => 'Pertamina',
            'name' => 'Pertamax Turbo',
            'octane' => '98',
            'national_price' => 14400.00,
        ]);

        $dexlite = Fuel::create([
            'id' => 4,
            'brand' => 'Pertamina',
            'name' => 'Dexlite',
            'octane' => 'D', // CN 51
            'national_price' => 14550.00,
        ]);

        $dex = Fuel::create([
            'id' => 5,
            'brand' => 'Pertamina',
            'name' => 'Pertamina Dex',
            'octane' => 'D+', // CN 53
            'national_price' => 15100.00,
        ]);

        // ============================================================
        // 2. Attach Fuel ke Place (Harga Nasional Sama untuk Semua SPBU)
        // ============================================================
        // Aturan ketersediaan:
        // - SPBU COCO   : Semua jenis BBM (Pertalite, Pertamax, Turbo, Dexlite, Dex)
        // - SPBU Reguler: Pertalite, Pertamax, Dexlite, Dex (umumnya tanpa Turbo)
        //   * Khusus SPBU Reguler kelas premium / dekat kawasan elite : + Pertamax Turbo
        // - Pertashop   : Hanya Pertamax
        // ============================================================

        // Bundle paket BBM
        $allFuels = [
            $pertalite->id     => ['is_available' => true, 'price' => 10000.00],
            $pertamax->id      => ['is_available' => true, 'price' => 12950.00],
            $turbo->id         => ['is_available' => true, 'price' => 14400.00],
            $dexlite->id       => ['is_available' => true, 'price' => 14550.00],
            $dex->id           => ['is_available' => true, 'price' => 15100.00],
        ];

        $regulerWithTurbo = [
            $pertalite->id     => ['is_available' => true, 'price' => 10000.00],
            $pertamax->id      => ['is_available' => true, 'price' => 12950.00],
            $turbo->id         => ['is_available' => true, 'price' => 14400.00],
            $dexlite->id       => ['is_available' => true, 'price' => 14550.00],
            $dex->id           => ['is_available' => true, 'price' => 15100.00],
        ];

        $regulerStandard = [
            $pertalite->id     => ['is_available' => true, 'price' => 10000.00],
            $pertamax->id      => ['is_available' => true, 'price' => 12950.00],
            $dexlite->id       => ['is_available' => true, 'price' => 14550.00],
            $dex->id           => ['is_available' => true, 'price' => 15100.00],
        ];

        $pertashopOnly = [
            $pertamax->id      => ['is_available' => true, 'price' => 12950.00],
        ];

        $fuelMap = [
            1 => $allFuels,         // COCO Dr. Soetomo
            2 => $allFuels,         // COCO MERR Kalijudan
            3 => $regulerStandard,  // Reguler Jemursari
            4 => $pertashopOnly,    // Pertashop Kenjeran
        ];

        foreach ($fuelMap as $placeId => $fuelData) {
            $place = Place::find($placeId);
            if ($place) {
                $place->fuels()->attach($fuelData);
            }
        }
    }
}
