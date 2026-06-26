<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Category::create([
            'name' => 'SPBU Reguler',
            'icon' => 'spbu_reguler.png'
        ]);

        Category::create([
            'name' => 'SPBU COCO',
            'icon' => 'spbu_coco.png'
        ]);

        Category::create([
            'name' => 'Pertashop',
            'icon' => 'pertashop.png'
        ]);
    }
}