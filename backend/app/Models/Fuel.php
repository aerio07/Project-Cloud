<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Fuel extends Model
{
    protected $fillable = [
        'brand',
        'name',
        'octane',
        'national_price',
    ];

    public function places()
    {
        return $this->belongsToMany(Place::class, 'place_fuel')
            ->withPivot(['is_available', 'price'])
            ->withTimestamps();
    }
}
