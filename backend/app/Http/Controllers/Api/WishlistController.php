<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Wishlist;
use App\Models\User;
use App\Models\Place;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class WishlistController extends Controller
{
    private function getAuthenticatedUser(Request $request)
    {
        $token = $request->header('Authorization');
        if ($token && str_starts_with($token, 'Bearer ')) {
            $token = substr($token, 7);
        }

        if (!$token) {
            return null;
        }

        return User::where('api_token', $token)->first();
    }

    public function index(Request $request)
    {
        $user = $this->getAuthenticatedUser($request);
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        // Ambil daftar places yang ada di wishlist user
        $wishlistItems = Wishlist::where('user_id', $user->id)
            ->with(['place.category', 'place.fuels', 'place.facilities'])
            ->get();

        $places = $wishlistItems->map(function ($item) {
            return $item->place;
        })->filter();

        return response()->json([
            'success' => true,
            'data' => $places->values()
        ]);
    }

    public function store(Request $request)
    {
        $user = $this->getAuthenticatedUser($request);
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        $validator = Validator::make($request->all(), [
            'place_id' => 'required|exists:places,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        // Cek jika sudah ada
        $exists = Wishlist::where('user_id', $user->id)
            ->where('place_id', $request->place_id)
            ->exists();

        if ($exists) {
            return response()->json([
                'success' => true,
                'message' => 'SPBU sudah ada di wishlist.'
            ]);
        }

        Wishlist::create([
            'user_id' => $user->id,
            'place_id' => $request->place_id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Berhasil menambahkan ke wishlist.'
        ], 201);
    }

    public function destroy(Request $request, $placeId)
    {
        $user = $this->getAuthenticatedUser($request);
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        $deleted = Wishlist::where('user_id', $user->id)
            ->where('place_id', $placeId)
            ->delete();

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Item wishlist tidak ditemukan.'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Berhasil menghapus dari wishlist.'
        ]);
    }
}
