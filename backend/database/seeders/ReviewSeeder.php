<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Review;

class ReviewSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Review::create([
            'place_id' => 1,
            'user_name' => 'Budi Santoso',
            'rating' => 5,
            'comment' => 'SPBU paling lengkap di Surabaya Pusat. Toiletnya sangat bersih, mushola juga terawat baik. Pilihan Bright Store-nya lengkap.'
        ]);

        Review::create([
            'place_id' => 1,
            'user_name' => 'Siti Aminah',
            'rating' => 4,
            'comment' => 'Fasilitas sangat lengkap, nyaman untuk istirahat sejenak setelah perjalanan jauh. Antrean Pertamax terkadang agak panjang saat jam pulang kantor.'
        ]);

        Review::create([
            'place_id' => 2,
            'user_name' => 'David Prasetyo',
            'rating' => 5,
            'comment' => 'Pelayanannya cepat. Pengisian nitrogen otomatis berfungsi dengan baik. Sangat terbantu saat ban kurang angin.'
        ]);

        Review::create([
            'place_id' => 3,
            'user_name' => 'Ahmad Rian',
            'rating' => 4,
            'comment' => 'Lokasi strategis di Jemursari. Sayangnya belum buka 24 jam penuh, namun layanannya tetap ramah dan takarannya pas.'
        ]);

        Review::create([
            'place_id' => 4,
            'user_name' => 'Rina Wijaya',
            'rating' => 4,
            'comment' => 'Sangat praktis untuk warga sekitar Kenjeran yang butuh Pertamax cepat tanpa harus ke SPBU besar.'
        ]);
    }
}