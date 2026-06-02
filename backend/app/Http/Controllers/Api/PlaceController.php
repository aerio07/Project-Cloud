<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Place;
use Illuminate\Http\Request;

class PlaceController extends Controller
{
    public function index(Request $request)
    {
        $query = Place::with('category');

        // filter kategori
        if ($request->has('category')) {
            $query->whereHas('category', function ($q) use ($request) {
                $q->where('name', $request->category);
            });
        }

        $places = $query->get();

        return response()->json([
            'success' => true,
            'data' => $places
        ]);
    }

    public function show($id)
    {
        $place = Place::with(['category', 'reviews'])
                    ->find($id);

        if (!$place) {
            return response()->json([
                'success' => false,
                'message' => 'Place not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $place
        ]);
    }
}