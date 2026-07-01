<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Seed an admin account when credentials are explicitly configured.
     */
    public function run(): void
    {
        $email = config('admin.email');
        $password = config('admin.password');
        $username = config('admin.username', 'admin');

        if (!$email || !$password) {
            $this->command?->warn('ADMIN_EMAIL dan ADMIN_PASSWORD belum diisi. AdminSeeder dilewati.');
            return;
        }

        $user = User::where('email', $email)->first()
            ?? User::where('username', $username)->first()
            ?? new User();

        $user->fill([
            'name' => config('admin.name', 'Administrator'),
            'username' => $username,
            'email' => $email,
            'password' => Hash::make($password),
            'role' => 'admin',
        ]);

        $user->save();

        $this->command?->info("Admin account ready: {$email}");
    }
}
