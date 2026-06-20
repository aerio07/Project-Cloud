<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Fuel extends Model
{
    protected $fillable = [
        'name',
        'octane',
        'national_price',
    ];

    public function places()
    {
        return $this->belongsToMany(Place::class)
            ->withPivot(['is_available', 'price'])
            ->withTimestamps();
    }
}
