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
        ];

        foreach ($facilityMap as $placeId => $facilityIds) {
            $place = Place::find($placeId);
            if ($place) {
                $place->facilities()->attach($facilityIds);
            }
        }

    }
}
