<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Review;

class ReviewController extends Controller
{
    public function index()
    {
        $reviews = Review::with('place')->get();

        return response()->json([
            'success' => true,
            'data' => $reviews
        ]);
    }
}