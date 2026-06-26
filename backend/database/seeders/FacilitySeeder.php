<?php

namespace Database\Seeders;

use App\Models\Facility;
use App\Models\Place;
use Illuminate\Database\Seeder;

class FacilitySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Master Facility
        $toilet = Facility::create([
            'id' => 1,
            'name' => 'Toilet',
            'icon' => 'wc_rounded'
        ]);

        $mushola = Facility::create([
            'id' => 2,
            'name' => 'Mushola',
            'icon' => 'mosque_rounded'
        ]);

        $minimarket = Facility::create([
            'id' => 3,
            'name' => 'Minimarket',
            'icon' => 'storefront_rounded'
        ]);

        $atm = Facility::create([
            'id' => 4,
            'name' => 'ATM',
            'icon' => 'atm_rounded'
        ]);

        $nitrogen = Facility::create([
            'id' => 5,
            'name' => 'Nitrogen',
            'icon' => 'tire_repair_rounded'
        ]);

        $charging = Facility::create([
            'id' => 6,
            'name' => 'EV Charging',
            'icon' => 'ev_station_rounded'
        ]);

        // ============================================================
        // 2. Attach Fasilitas ke Tiap Place
        // ============================================================
        // Aturan umum:
        // - SPBU COCO (category 2)    : fasilitas TERLENGKAP (toilet, mushola, minimarket, atm, nitrogen, + sebagian EV)
        // - SPBU Reguler (category 1) : standar (toilet, mushola, atm, nitrogen) - sebagian + minimarket
        // - Pertashop (category 3)    : minimalis (toilet, nitrogen)
        // ============================================================

        $facilityMap = [
            1 => [$toilet->id, $mushola->id, $minimarket->id, $atm->id, $nitrogen->id, $charging->id], // COCO Dr. Soetomo - terlengkap
            2 => [$toilet->id, $mushola->id, $minimarket->id, $atm->id, $nitrogen->id],                // COCO MERR
            3 => [$toilet->id, $mushola->id, $atm->id, $nitrogen->id],                                 // Reguler Jemursari
            4 => [$toilet->id, $nitrogen->id],                                                         // Pertashop Kenjeran
            5  => [$toilet->id, $mushola->id, $atm->id, $nitrogen->id, $minimarket->id],               // 5  Ahmad Yani (Reguler ramai)
            6  => [$toilet->id, $mushola->id, $atm->id],                                               // 6  Margorejo (Reguler standar)
            7  => [$toilet->id, $mushola->id, $minimarket->id, $atm->id, $nitrogen->id, $charging->id],// 7  COCO Wiyung (terlengkap + EV)
            8  => [$toilet->id, $mushola->id, $nitrogen->id],                                          // 8  Karang Pilang (jalur truk)
            9  => [$toilet->id, $mushola->id, $minimarket->id, $atm->id, $nitrogen->id],               // 9  COCO Embong Malang
            10 => [$toilet->id, $mushola->id, $atm->id, $nitrogen->id, $minimarket->id],               // 10 Diponegoro (Reguler ramai)
            11 => [$toilet->id, $mushola->id, $atm->id],                                               // 11 Demak (Reguler lama)
            12 => [$toilet->id, $mushola->id, $minimarket->id, $atm->id, $nitrogen->id, $charging->id],// 12 COCO Tunjungan (premium)
            13 => [$toilet->id, $mushola->id, $minimarket->id, $atm->id, $nitrogen->id],               // 13 Mayjen Sungkono (Reguler premium)
            14 => [$toilet->id, $mushola->id, $minimarket->id, $atm->id, $nitrogen->id, $charging->id],// 14 COCO HR Muhammad (elite)
            15 => [$toilet->id, $mushola->id, $atm->id, $nitrogen->id],                                // 15 Darmo Permai
            16 => [$toilet->id, $mushola->id, $nitrogen->id],                                          // 16 Tandes (industri)
            17 => [$toilet->id, $mushola->id, $minimarket->id, $atm->id, $nitrogen->id, $charging->id],// 17 COCO Pakuwon Indah
            18 => [$toilet->id, $mushola->id, $nitrogen->id],                                          // 18 Kalianak (industri)
            19 => [$toilet->id, $mushola->id, $atm->id],                                               // 19 Perak Barat
            20 => [$toilet->id, $nitrogen->id],                                                        // 20 Pertashop Bulak Setro
            21 => [$toilet->id, $mushola->id, $minimarket->id, $atm->id, $nitrogen->id],               // 21 COCO Rungkut Industri
            22 => [$toilet->id, $mushola->id, $minimarket->id, $atm->id, $nitrogen->id],               // 22 Manyar Kertoarjo
            23 => [$toilet->id, $mushola->id, $minimarket->id, $atm->id, $nitrogen->id],               // 23 Kertajaya Indah (dekat kampus)
            24 => [$toilet->id, $mushola->id, $atm->id, $nitrogen->id],                                // 24 Gunung Anyar
        ];

        foreach ($facilityMap as $placeId => $facilityIds) {
            $place = Place::find($placeId);
            if ($place) {
                $place->facilities()->attach($facilityIds);
            }
        }
    }
}
