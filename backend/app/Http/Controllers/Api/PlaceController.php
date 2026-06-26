<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Place;
use Illuminate\Http\Request;

class PlaceController extends Controller
{
    public function index(Request $request)
{
    $places = Place::with(['category', 'fuels', 'facilities'])
        ->withFilters($request)
        ->get();

    return response()->json([
        'success' => true,
        'data' => $places,
    ]);
}

    public function show($id)
    {
        $place = Place::with(['category', 'reviews', 'fuels', 'facilities'])
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