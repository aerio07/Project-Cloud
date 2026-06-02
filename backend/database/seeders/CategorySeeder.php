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
            'name' => 'Cafe',
            'icon' => 'cafe.png'
        ]);

        Category::create([
            'name' => 'Kantin',
            'icon' => 'kantin.png'
        ]);

        Category::create([
            'name' => 'ATM',
            'icon' => 'atm.png'
        ]);

        Category::create([
            'name' => 'Fotokopi',
            'icon' => 'fotokopi.png'
        ]);
    }
}