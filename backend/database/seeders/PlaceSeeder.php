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

        // --- SURABAYA SELATAN ---
        Place::create([
            'id' => 5,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Ahmad Yani (54.601.10)',
            'address' => 'Jl. Ahmad Yani No.286, Gayungan, Surabaya',
            'latitude' => -7.3267,
            'longitude' => 112.7330,
            'description' => 'SPBU Reguler di jalur utama Ahmad Yani, akses langsung dari/ke Bandara Juanda dan Tol Waru. Strategis untuk pengendara komuter Surabaya - Sidoarjo dengan antrian cepat di 8 nozzle.',
            'rating' => 4.4,
            'photo_url' => 'https://images.unsplash.com/photo-1545459720-aac8509eb02c?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 6,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Margorejo (54.601.18)',
            'address' => 'Jl. Margorejo Indah Blok A-1, Wonocolo, Surabaya',
            'latitude' => -7.3179,
            'longitude' => 112.7430,
            'description' => 'SPBU di kawasan perumahan padat Margorejo. Melayani BBM Gasoline & Diesel dengan fasilitas Mushola dan Toilet bersih. Cocok untuk pengisian harian warga Surabaya Selatan.',
            'rating' => 4.2,
            'photo_url' => 'https://images.unsplash.com/photo-1545459720-aac8509eb02c?w=500',
            'opening_hours' => '05:00 - 23:00'
        ]);

        Place::create([
            'id' => 7,
            'category_id' => 2, // SPBU COCO
            'name' => 'SPBU Pertamina COCO Wiyung (51.601.40)',
            'address' => 'Jl. Raya Menganti Wiyung No.12, Wiyung, Surabaya',
            'latitude' => -7.3194,
            'longitude' => 112.6905,
            'description' => 'SPBU COCO modern di Surabaya Barat Daya dengan fasilitas lengkap: Bright Store, Mushola besar, ATM, dan Nitrogen. Tersedia EV Charging untuk kendaraan listrik.',
            'rating' => 4.6,
            'photo_url' => 'https://images.unsplash.com/photo-1606768666853-403c90a981ad?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 8,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Karang Pilang (54.601.21)',
            'address' => 'Jl. Mastrip No.78, Karang Pilang, Surabaya',
            'latitude' => -7.3461,
            'longitude' => 112.6985,
            'description' => 'SPBU di jalur Mastrip yang menghubungkan Surabaya - Mojokerto. Banyak melayani truk dan kendaraan logistik. Dilengkapi area parkir luas dan toilet umum.',
            'rating' => 4.1,
            'photo_url' => 'https://images.unsplash.com/photo-1542228262-3d663b306a53?w=500',
            'opening_hours' => '24 Jam'
        ]);

        // --- SURABAYA PUSAT ---
        Place::create([
            'id' => 9,
            'category_id' => 2, // SPBU COCO
            'name' => 'SPBU Pertamina COCO Embong Malang (51.601.12)',
            'address' => 'Jl. Embong Malang No.45, Tegalsari, Surabaya',
            'latitude' => -7.2620,
            'longitude' => 112.7402,
            'description' => 'SPBU COCO premium di jantung pusat kota Surabaya, dekat Tunjungan Plaza. Layanan Self Service & petugas, Bright Cafe, dan dispenser modern dengan akurasi takaran terjamin.',
            'rating' => 4.7,
            'photo_url' => 'https://images.unsplash.com/photo-1527018601619-a508a2be00cd?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 10,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Diponegoro (54.601.22)',
            'address' => 'Jl. Diponegoro No.151, Darmo, Wonokromo, Surabaya',
            'latitude' => -7.2766,
            'longitude' => 112.7359,
            'description' => 'SPBU strategis di Jl. Diponegoro yang menghubungkan Darmo - Wonokromo. Salah satu SPBU paling sibuk di Surabaya, dengan 10 nozzle untuk minimasi antrian.',
            'rating' => 4.3,
            'photo_url' => 'https://images.unsplash.com/photo-1545459720-aac8509eb02c?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 11,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Demak (54.601.25)',
            'address' => 'Jl. Demak No.205, Krembangan, Surabaya',
            'latitude' => -7.2421,
            'longitude' => 112.7271,
            'description' => 'SPBU lama di kawasan Demak yang melayani Surabaya Pusat & Utara. Akses mudah dari Jl. Rajawali dan kawasan Tanjung Perak. Buka 24 jam.',
            'rating' => 4.0,
            'photo_url' => 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 12,
            'category_id' => 2, // SPBU COCO
            'name' => 'SPBU Pertamina COCO Tunjungan (51.601.60)',
            'address' => 'Jl. Tunjungan No.78, Genteng, Surabaya',
            'latitude' => -7.2587,
            'longitude' => 112.7378,
            'description' => 'SPBU COCO ikonik di Jl. Tunjungan, kawasan bersejarah Surabaya. Bangunan modern dengan kanopi tinggi, Bright Store 24 jam, ATM, dan lounge istirahat ber-AC.',
            'rating' => 4.8,
            'photo_url' => 'https://images.unsplash.com/photo-1622060822165-35bc3c448f71?w=500',
            'opening_hours' => '24 Jam'
        ]);

        // --- SURABAYA BARAT ---
        Place::create([
            'id' => 13,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Mayjen Sungkono (54.601.15)',
            'address' => 'Jl. Mayjen Sungkono No.124, Dukuh Pakis, Surabaya',
            'latitude' => -7.2882,
            'longitude' => 112.7150,
            'description' => 'SPBU di jalur bisnis Mayjen Sungkono, dekat Ciputra World & Pakuwon Mall. Pelayanan cepat untuk eksekutif dan pengendara komersial.',
            'rating' => 4.5,
            'photo_url' => 'https://images.unsplash.com/photo-1606768666853-403c90a981ad?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 14,
            'category_id' => 2, // SPBU COCO
            'name' => 'SPBU Pertamina COCO HR Muhammad (51.601.20)',
            'address' => 'Jl. HR Muhammad No.41, Putat Gede, Sukomanunggal, Surabaya',
            'latitude' => -7.2811,
            'longitude' => 112.6856,
            'description' => 'SPBU COCO megah di kawasan elite HR Muhammad. Pelayanan profesional, Bright Cafe dengan kopi premium, EV Charging Station, dan car wash terintegrasi.',
            'rating' => 4.8,
            'photo_url' => 'https://images.unsplash.com/photo-1527018601619-a508a2be00cd?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 15,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Darmo Permai (54.601.48)',
            'address' => 'Jl. Darmo Permai III No.5, Sukomanunggal, Surabaya',
            'latitude' => -7.2858,
            'longitude' => 112.6948,
            'description' => 'SPBU di kawasan perumahan Darmo Permai. Fasilitas standard lengkap dengan Mushola, Toilet, dan ATM. Akses cepat ke Tol Satelit.',
            'rating' => 4.2,
            'photo_url' => 'https://images.unsplash.com/photo-1542228262-3d663b306a53?w=500',
            'opening_hours' => '05:00 - 23:00'
        ]);

        Place::create([
            'id' => 16,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Tandes (54.601.42)',
            'address' => 'Jl. Raya Tandes Lor No.88, Tandes, Surabaya',
            'latitude' => -7.2493,
            'longitude' => 112.6781,
            'description' => 'SPBU di jalur industri Tandes - Margomulyo. Melayani kendaraan komersial dan truk logistik dengan dispenser solar berkapasitas tinggi.',
            'rating' => 4.1,
            'photo_url' => 'https://images.unsplash.com/photo-1545459720-aac8509eb02c?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 17,
            'category_id' => 2, // SPBU COCO
            'name' => 'SPBU Pertamina COCO Pakuwon Indah (51.601.50)',
            'address' => 'Jl. Puncak Indah Lontar No.2, Sambikerep, Surabaya',
            'latitude' => -7.2900,
            'longitude' => 112.6648,
            'description' => 'SPBU COCO baru di kawasan Pakuwon Indah & Citraland. Fasilitas terlengkap: Bright Store, ATM, EV Charging, Mushola, hingga Drive-Thru Bright Cafe.',
            'rating' => 4.7,
            'photo_url' => 'https://images.unsplash.com/photo-1606768666853-403c90a981ad?w=500',
            'opening_hours' => '24 Jam'
        ]);

        // --- SURABAYA UTARA ---
        Place::create([
            'id' => 18,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Kalianak (54.601.52)',
            'address' => 'Jl. Kalianak No.55, Asemrowo, Surabaya',
            'latitude' => -7.2381,
            'longitude' => 112.6925,
            'description' => 'SPBU di jalur akses pelabuhan Tanjung Perak via Kalianak. Banyak dikunjungi truk container dan kendaraan logistik. Tersedia solar industri.',
            'rating' => 4.0,
            'photo_url' => 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 19,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Perak Barat (54.601.55)',
            'address' => 'Jl. Perak Barat No.293, Pabean Cantian, Surabaya',
            'latitude' => -7.2110,
            'longitude' => 112.7327,
            'description' => 'SPBU di kawasan pelabuhan Tanjung Perak. Strategis untuk kendaraan menuju/dari pelabuhan dan terminal penumpang. Fasilitas standar dan parkir luas.',
            'rating' => 4.1,
            'photo_url' => 'https://images.unsplash.com/photo-1542228262-3d663b306a53?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 20,
            'category_id' => 3, // Pertashop
            'name' => 'Pertashop Bulak Setro (5P.601.05)',
            'address' => 'Jl. Bulak Setro Indah No.10, Bulak, Surabaya',
            'latitude' => -7.2335,
            'longitude' => 112.7780,
            'description' => 'Pertashop melayani warga Bulak dan sekitarnya dengan BBM Pertamax berkualitas. Lokasi dekat Pantai Kenjeran dan Suramadu.',
            'rating' => 4.3,
            'photo_url' => 'https://images.unsplash.com/photo-1580828343064-fde4fc206bc6?w=500',
            'opening_hours' => '06:00 - 22:00'
        ]);

        // --- SURABAYA TIMUR ---
        Place::create([
            'id' => 21,
            'category_id' => 2, // SPBU COCO
            'name' => 'SPBU Pertamina COCO Rungkut Industri (51.601.30)',
            'address' => 'Jl. Rungkut Industri Raya No.10, Rungkut, Surabaya',
            'latitude' => -7.3417,
            'longitude' => 112.7625,
            'description' => 'SPBU COCO besar di kawasan industri SIER Rungkut. Dispenser khusus solar industri untuk truk, Bright Store, Mushola, dan ATM lengkap.',
            'rating' => 4.6,
            'photo_url' => 'https://images.unsplash.com/photo-1622060822165-35bc3c448f71?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 22,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Manyar Kertoarjo (54.601.32)',
            'address' => 'Jl. Manyar Kertoarjo V No.20, Mulyorejo, Surabaya',
            'latitude' => -7.2785,
            'longitude' => 112.7676,
            'description' => 'SPBU di kawasan perumahan elite Manyar. Dekat dengan kampus ITS & Galaxy Mall. Pelayanan cepat dengan 6 dispenser dan area pengisian Nitrogen.',
            'rating' => 4.4,
            'photo_url' => 'https://images.unsplash.com/photo-1545459720-aac8509eb02c?w=500',
            'opening_hours' => '05:00 - 24:00'
        ]);

        Place::create([
            'id' => 23,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Kertajaya Indah (54.601.35)',
            'address' => 'Jl. Kertajaya Indah Tengah No.7, Sukolilo, Surabaya',
            'latitude' => -7.2826,
            'longitude' => 112.7900,
            'description' => 'SPBU dekat kampus ITS, Universitas Hang Tuah, dan ITATS. Banyak dikunjungi mahasiswa dan dosen. Tersedia fasilitas Mushola dan minimarket.',
            'rating' => 4.3,
            'photo_url' => 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=500',
            'opening_hours' => '24 Jam'
        ]);

        Place::create([
            'id' => 24,
            'category_id' => 1, // SPBU Reguler
            'name' => 'SPBU Pertamina Gunung Anyar (54.601.58)',
            'address' => 'Jl. Gunung Anyar Tengah No.45, Gunung Anyar, Surabaya',
            'latitude' => -7.3413,
            'longitude' => 112.7900,
            'description' => 'SPBU di Surabaya Timur perbatasan Sidoarjo, dekat akses Tol Gunung Anyar. Melayani komuter Surabaya - Sidoarjo dengan layanan cepat 24 jam.',
            'rating' => 4.2,
            'photo_url' => 'https://images.unsplash.com/photo-1542228262-3d663b306a53?w=500',
            'opening_hours' => '24 Jam'
        ]);
    }
}