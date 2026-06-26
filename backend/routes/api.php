<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Http;
use Illuminate\Http\Request;

use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\PlaceController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\WishlistController;

// ==============================
// BASIC API
// ==============================

Route::get('/categories', [CategoryController::class, 'index']);

Route::get('/places', [PlaceController::class, 'index']);

Route::get('/places/{id}', [PlaceController::class, 'show']);

Route::get('/reviews', [ReviewController::class, 'index']);

Route::get('/fuels', function () {
    return response()->json([
        'success' => true,
        'data' => \App\Models\Fuel::all()
    ]);
});


// ==============================
// AUTHENTICATION API
// ==============================

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout']);


// ==============================
// WISHLIST API
// ==============================

Route::get('/wishlists', [WishlistController::class, 'index']);
Route::post('/wishlists', [WishlistController::class, 'store']);
Route::delete('/wishlists/{place_id}', [WishlistController::class, 'destroy']);


// ==============================
// PRIVATE REVIEWS API
// ==============================

Route::post('/reviews', [ReviewController::class, 'store']);


// ==============================
// OPENROUTESERVICE DIRECTIONS
// ==============================

Route::get('/directions', function (Request $request) { $start = $request->start; $end = $request->end; $profile = $request->profile ?? 'driving-car'; try { $response = Http::withHeaders([ 'Authorization' => env('ORS_API_KEY'), 'Accept' => 'application/json', ])->post( 'https://api.openrouteservice.org/v2/directions/' . $profile, [ 'coordinates' => [ array_map('floatval', explode(',', $start)), array_map('floatval', explode(',', $end)), ] ] ); return response()->json( $response->json() ); } catch (\Exception $e) { return response()->json([ 'error' => true, 'message' => $e->getMessage() ], 500); } });