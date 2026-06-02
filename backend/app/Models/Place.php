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
}