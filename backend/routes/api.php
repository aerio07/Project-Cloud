<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\Request;

use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\PlaceController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\WishlistController;
use App\Http\Controllers\Api\AdminController;

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
// ADMIN API
// ==============================

Route::prefix('admin')->middleware('admin.token')->group(function () {
    Route::get('/dashboard', [AdminController::class, 'dashboard']);

    // SPBU
    Route::get('/places', [AdminController::class, 'indexPlaces']);
    Route::post('/places', [AdminController::class, 'storePlace']);
    Route::post('/places/{id}', [AdminController::class, 'updatePlace']);
    Route::delete('/places/{id}', [AdminController::class, 'destroyPlace']);

    // BBM
    Route::get('/fuels', [AdminController::class, 'indexFuels']);
    Route::post('/fuels', [AdminController::class, 'storeFuel']);
    Route::put('/fuels/{id}', [AdminController::class, 'updateFuel']);

    // Kategori
    Route::get('/categories', [AdminController::class, 'indexCategories']);
    Route::post('/categories', [AdminController::class, 'storeCategory']);
    Route::put('/categories/{id}', [AdminController::class, 'updateCategory']);

    // Fasilitas
    Route::get('/facilities', [AdminController::class, 'indexFacilities']);
    Route::post('/facilities', [AdminController::class, 'storeFacility']);
    Route::put('/facilities/{id}', [AdminController::class, 'updateFacility']);
});


// ==============================
// OPENROUTESERVICE DIRECTIONS
// ==============================

Route::get('/directions', function (Request $request) {
    $validator = Validator::make($request->all(), [
        'start' => ['required', 'regex:/^-?\d+(\.\d+)?,-?\d+(\.\d+)?$/'],
        'end' => ['required', 'regex:/^-?\d+(\.\d+)?,-?\d+(\.\d+)?$/'],
        'profile' => ['nullable', 'in:driving-car,driving-hgv,cycling-regular,foot-walking'],
    ]);

    if ($validator->fails()) {
        return response()->json([
            'success' => false,
            'errors' => $validator->errors(),
        ], 422);
    }

    $profile = $request->profile ?? 'driving-car';
    $coordinates = [
        array_map('floatval', explode(',', $request->start)),
        array_map('floatval', explode(',', $request->end)),
    ];

    if (!env('ORS_API_KEY')) {
        return response()->json([
            'success' => false,
            'message' => 'ORS_API_KEY belum diatur di file .env.',
        ], 500);
    }

    try {
        $http = Http::withHeaders([
            'Authorization' => env('ORS_API_KEY'),
            'Accept' => 'application/json',
        ])->timeout(20);

        if (app()->environment('local')) {
            $http = $http->withoutVerifying();
        }

        $response = $http->post('https://api.openrouteservice.org/v2/directions/' . $profile, [
            'coordinates' => $coordinates,
        ]);

        $data = $response->json();

        if (!$response->successful()) {
            return response()->json([
                'success' => false,
                'message' => $data['error']['message']
                    ?? $data['message']
                    ?? 'OpenRouteService gagal membuat rute.',
                'details' => $data,
            ], $response->status());
        }

        if (empty($data['routes'])) {
            return response()->json([
                'success' => false,
                'message' => 'Rute tidak ditemukan. Pastikan lokasi awal dan tujuan masih berada di jaringan jalan yang dapat dilalui.',
                'details' => $data,
            ], 404);
        }

        return response()->json($data);
    } catch (\Exception $e) {
        $message = $e->getMessage();
        if (str_contains($message, 'cURL error 60')) {
            $message = 'SSL certificate PHP/cURL bermasalah saat menghubungi OpenRouteService. Untuk production, pasang CA certificate yang valid di php.ini.';
        }

        return response()->json([
            'success' => false,
            'error' => true,
            'message' => $message,
        ], 500);
    }
});
