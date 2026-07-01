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
            5  => $regulerWithTurbo, // 5  Ahmad Yani (Reguler ramai, premium)
            6  => $regulerStandard,  // 6  Margorejo
            7  => $allFuels,         // 7  COCO Wiyung
            8  => $regulerStandard,  // 8  Karang Pilang (jalur truk)
            9  => $allFuels,         // 9  COCO Embong Malang
            10 => $regulerWithTurbo, // 10 Diponegoro (Reguler kawasan premium)
            11 => $regulerStandard,  // 11 Demak
            12 => $allFuels,         // 12 COCO Tunjungan
            13 => $regulerWithTurbo, // 13 Mayjen Sungkono (kawasan elite)
            14 => $allFuels,         // 14 COCO HR Muhammad
            15 => $regulerStandard,  // 15 Darmo Permai
            16 => $regulerStandard,  // 16 Tandes (industri)
            17 => $allFuels,         // 17 COCO Pakuwon Indah
            18 => $regulerStandard,  // 18 Kalianak (industri/pelabuhan)
            19 => $regulerStandard,  // 19 Perak Barat
            20 => $pertashopOnly,    // 20 Pertashop Bulak Setro
            21 => $allFuels,         // 21 COCO Rungkut Industri
            22 => $regulerWithTurbo, // 22 Manyar Kertoarjo (kawasan elite)
            23 => $regulerStandard,  // 23 Kertajaya Indah (kampus)
            24 => $regulerStandard,  // 24 Gunung Anyar
        ];

        foreach ($fuelMap as $placeId => $fuelData) {
            $place = Place::find($placeId);
            if ($place) {
                $place->fuels()->attach($fuelData);
            }
        }
    }
}
