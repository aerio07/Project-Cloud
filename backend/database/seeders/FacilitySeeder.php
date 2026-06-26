<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Facility;
use App\Models\Place;

class FacilitySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Create Facilities
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

        // 2. Attach to Places
        // Place 1: SPBU COCO Dr. Soetomo (Fasilitas Terlengkap)
        $place1 = Place::find(1);
        if ($place1) {
            $place1->facilities()->attach([
                $toilet->id,
                $mushola->id,
                $minimarket->id,
                $atm->id,
                $nitrogen->id,
                $charging->id
            ]);
        }

        // Place 2: SPBU COCO MERR (Lengkap minus EV Charging)
        $place2 = Place::find(2);
        if ($place2) {
            $place2->facilities()->attach([
                $toilet->id,
                $mushola->id,
                $minimarket->id,
                $atm->id,
                $nitrogen->id
            ]);
        }

        // Place 3: SPBU Jemursari (Standard)
        $place3 = Place::find(3);
        if ($place3) {
            $place3->facilities()->attach([
                $toilet->id,
                $mushola->id,
                $atm->id,
                $nitrogen->id
            ]);
        }

        // Place 4: Pertashop (Minimalis)
        $place4 = Place::find(4);
        if ($place4) {
            $place4->facilities()->attach([
                $toilet->id,
                $nitrogen->id
            ]);
        }
    }
}
