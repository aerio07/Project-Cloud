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

        // Place 5: SPBU Ahmad Yani (Reguler ramai)
$place5 = Place::find(5);
if ($place5) {
    $place5->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $atm->id,
        $nitrogen->id,
        $minimarket->id
    ]);
}

// Place 6: SPBU Margorejo (Reguler standar)
$place6 = Place::find(6);
if ($place6) {
    $place6->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $atm->id
    ]);
}

// Place 7: SPBU COCO Wiyung (Terlengkap + EV)
$place7 = Place::find(7);
if ($place7) {
    $place7->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $minimarket->id,
        $atm->id,
        $nitrogen->id,
        $charging->id
    ]);
}

// Place 8: SPBU Karang Pilang (Jalur truk)
$place8 = Place::find(8);
if ($place8) {
    $place8->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $nitrogen->id
    ]);
}

// Place 9: SPBU COCO Embong Malang
$place9 = Place::find(9);
if ($place9) {
    $place9->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $minimarket->id,
        $atm->id,
        $nitrogen->id
    ]);
}

// Place 10: SPBU Diponegoro (Reguler ramai)
$place10 = Place::find(10);
if ($place10) {
    $place10->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $atm->id,
        $nitrogen->id,
        $minimarket->id
    ]);
}

// Place 11: SPBU Demak (Reguler lama)
$place11 = Place::find(11);
if ($place11) {
    $place11->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $atm->id
    ]);
}

// Place 12: SPBU COCO Tunjungan (Premium)
$place12 = Place::find(12);
if ($place12) {
    $place12->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $minimarket->id,
        $atm->id,
        $nitrogen->id,
        $charging->id
    ]);
}

// Place 13: SPBU Mayjen Sungkono (Reguler premium)
$place13 = Place::find(13);
if ($place13) {
    $place13->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $minimarket->id,
        $atm->id,
        $nitrogen->id
    ]);
}

// Place 14: SPBU COCO HR Muhammad (Elite)
$place14 = Place::find(14);
if ($place14) {
    $place14->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $minimarket->id,
        $atm->id,
        $nitrogen->id,
        $charging->id
    ]);
}

// Place 15: SPBU Darmo Permai
$place15 = Place::find(15);
if ($place15) {
    $place15->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $atm->id,
        $nitrogen->id
    ]);
}

// Place 16: SPBU Tandes (Industri)
$place16 = Place::find(16);
if ($place16) {
    $place16->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $nitrogen->id
    ]);
}

// Place 17: SPBU COCO Pakuwon Indah
$place17 = Place::find(17);
if ($place17) {
    $place17->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $minimarket->id,
        $atm->id,
        $nitrogen->id,
        $charging->id
    ]);
}

// Place 18: SPBU Kalianak (Industri)
$place18 = Place::find(18);
if ($place18) {
    $place18->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $nitrogen->id
    ]);
}

// Place 19: SPBU Perak Barat
$place19 = Place::find(19);
if ($place19) {
    $place19->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $atm->id
    ]);
}

// Place 20: Pertashop Bulak Setro
$place20 = Place::find(20);
if ($place20) {
    $place20->facilities()->attach([
        $toilet->id,
        $nitrogen->id
    ]);
}

// Place 21: SPBU COCO Rungkut Industri
$place21 = Place::find(21);
if ($place21) {
    $place21->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $minimarket->id,
        $atm->id,
        $nitrogen->id
    ]);
}

// Place 22: SPBU Manyar Kertoarjo
$place22 = Place::find(22);
if ($place22) {
    $place22->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $minimarket->id,
        $atm->id,
        $nitrogen->id
    ]);
}

// Place 23: SPBU Kertajaya Indah (Dekat kampus)
$place23 = Place::find(23);
if ($place23) {
    $place23->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $minimarket->id,
        $atm->id,
        $nitrogen->id
    ]);
}

// Place 24: SPBU Gunung Anyar
$place24 = Place::find(24);
if ($place24) {
    $place24->facilities()->attach([
        $toilet->id,
        $mushola->id,
        $atm->id,
        $nitrogen->id
    ]);
}
    }
}
