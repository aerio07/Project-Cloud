<?php

namespace Database\Seeders;

use App\Models\Place;
use Illuminate\Database\Seeder;

class PlaceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // ============================================================
        // DATA SPBU 
        // ============================================================
        Place::create([
            'id' => 1,
            'category_id' => 2, // SPBU COCO
            'name' => 'SPBU Pertamina COCO Dr. Soetomo (51.601.65)',
            'address' => 'Jl. Raya Dr. Soetomo No.88, Tegalsari, Surabaya',
            'latitude' => -7.2694,
            'longitude' => 112.7381,
            'description' => 'SPBU Pertamina COCO (Company Owned Company Operated) yang strategis di pusat kota Surabaya. Menyediakan fasilitas pengisian bahan bakar terlengkap, Bright Store, ATM Center, Toilet bersih, dan tempat istirahat yang nyaman.',
            'rating' => 4.7,
            'photo_url' => 'https://images.unsplash.com/photo-1527018601619-a508a2be00cd?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 2,
            'category_id' => 2, // SPBU COCO
            'name' => 'SPBU Pertamina COCO MERR Kalijudan (31.601.01)',
            'address' => 'Jl. Dr. Ir. H. Soekarno No.99, Kalijudan, Mulyorejo, Surabaya',
            'latitude' => -7.2618,
            'longitude' => 112.7845,
            'description' => 'SPBU Pertamina COCO yang berlokasi di jalur MERR Surabaya Timur. Dilengkapi dengan pelayanan Self Service dan petugas, pengisian angin Nitrogen, Toilet bersih, Mushola yang luas, serta gerai minimarket Bright Store.',
            'rating' => 4.5,
            'photo_url' => 'https://images.unsplash.com/photo-1622060822165-35bc3c448f71?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 3,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Jemursari (34.601.03)',
            'address' => 'Jl. Raya Jemursari No.120, Wonocolo, Surabaya',
            'latitude' => -7.3194,
            'longitude' => 112.7512,
            'description' => 'SPBU Reguler Pertamina di daerah Jemursari yang melayani pengisian BBM Gasoline dan Diesel. Memiliki fasilitas penunjang lengkap termasuk ATM Center, tempat ibadah Mushola, dan Nitrogen.',
            'rating' => 4.3,
            'photo_url' => 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=500',
            'opening_hours' => '06:00 - 23:00'
        ]);

        Place::create([
            'id' => 4,
            'category_id' => 3, // Pertashop
            'name' => 'Pertashop Pertamina Kenjeran (5P.601.01)',
            'address' => 'Jl. Kenjeran No.400, Gading, Tambaksari, Surabaya',
            'latitude' => -7.2483,
            'longitude' => 112.7725,
            'description' => 'Pertashop resmi Pertamina untuk pengisian BBM Pertamax berkualitas tinggi dengan takaran pas. Menjangkau kebutuhan bahan bakar harian bagi pengendara di sekitar area Kenjeran.',
            'rating' => 4.4,
            'photo_url' => 'https://images.unsplash.com/photo-1580828343064-fde4fc206bc6?w=500',
            'opening_hours' => '06:00 - 22:00'
        ]);

    }
}
