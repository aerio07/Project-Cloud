<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Place extends Model
{
    protected $fillable = [
        'category_id',
        'name',
        'address',
        'latitude',
        'longitude',
        'description',
        'rating',
        'photo_url',
        'opening_hours'
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function fuels()
    {
        return $this->belongsToMany(Fuel::class)
            ->withPivot(['is_available', 'price'])
            ->withTimestamps();
    }

    public function facilities()
    {
        return $this->belongsToMany(Facility::class)
            ->withTimestamps();
    }

    public function scopeWithFilters($query, $request)
{
    return $query
        ->when($request->filled('fuel'), function ($query) use ($request) {
            $query->whereHas('fuels', function ($query) use ($request) {
                $query->where('name', $request->fuel)
                    ->where('place_fuel.is_available', true);
            });
        })
        ->when($request->filled('facility'), function ($query) use ($request) {
            $query->whereHas('facilities', function ($query) use ($request) {
                $query->where('name', $request->facility);
            });
        });
}
}
