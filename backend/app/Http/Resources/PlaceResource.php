<?php

namespace App\Http\Resources;

use Illuminate\Http\Resources\Json\JsonResource;

class PlaceResource extends JsonResource
{
    public function toArray($request): array
    {
        return [
            'id'            => $this->id,
            'category_id'   => $this->category_id,
            'name'          => $this->name,
            'address'       => $this->address,
            'latitude'      => (float) $this->latitude,
            'longitude'     => (float) $this->longitude,
            'description'   => $this->description,
            'rating'        => (float) $this->rating,
            'photo_url'     => $this->photo_url,
            'opening_hours' => $this->opening_hours,
            'category'      => $this->whenLoaded('category'),
            'facilities'    => $this->whenLoaded('facilities', function () {
                return $this->facilities->map(fn ($f) => [
                    'id'   => $f->id,
                    'name' => $f->name,
                    'icon' => $f->icon,
                ]);
            }),
            'fuels'         => $this->whenLoaded('fuels', function () {
                return $this->fuels->map(fn ($fuel) => [
                    'id'           => $fuel->id,
                    'name'         => $fuel->name,
                    'octane'       => $fuel->octane,
                    'price'        => (float) $fuel->pivot->price,
                    'is_available' => (bool) $fuel->pivot->is_available,
                ]);
            }),
'reviews' => $this->whenLoaded('reviews', function () {
    return $this->reviews->map(function ($review) {
        return [
            'id' => $review->id,
            'user_name' => $review->user_name,
            'rating' => $review->rating,
            'comment' => $review->comment,
            'created_at' => $review->created_at,
        ];
    });
}),
            'created_at'    => $this->created_at,
            'updated_at'    => $this->updated_at,
        ];
    }
}