<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StorePlaceRequest;
use App\Http\Requests\UpdatePlaceRequest;
use App\Http\Resources\PlaceResource;
use App\Models\Place;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Throwable;

class PlaceController extends Controller
{
    /**
     * GET /api/places
     */
    public function index(Request $request)
    {
        $places = Place::with(['category', 'fuels', 'facilities'])
            ->withFilters($request)
            ->get();

        return response()->json([
            'success' => true,
            'data'    => $places,
        ]);
    }

    /**
     * GET /api/places/{id}
     */
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
            'data'    => new PlaceResource($place),
        ]);
    }

    /**
     * POST /api/places
     */
    public function store(StorePlaceRequest $request)
    {
        $data = $request->validated();

        try {
            $place = DB::transaction(function () use ($data) {
                // 1. Create place
                $place = Place::create([
                    'category_id'   => $data['category_id'],
                    'name'          => $data['name'],
                    'address'       => $data['address'],
                    'latitude'      => $data['latitude'],
                    'longitude'     => $data['longitude'],
                    'description'   => $data['description']   ?? null,
                    'rating'        => $data['rating']        ?? 0,
                    'photo_url'     => $data['photo_url']     ?? null,
                    'opening_hours' => $data['opening_hours'],
                ]);

                // 2. Attach facilities (facility_place)
                if (!empty($data['facility_ids'])) {
                    $place->facilities()->sync($data['facility_ids']);
                }

                // 3. Attach fuels with pivot (place_fuel)
                if (!empty($data['fuels'])) {
                    $fuelSync = [];
                    foreach ($data['fuels'] as $fuel) {
                        $fuelSync[$fuel['id']] = [
                            'price'        => $fuel['price'],
                            'is_available' => (bool) $fuel['is_available'],
                        ];
                    }
                    $place->fuels()->sync($fuelSync);
                }

                return $place;
            });

            $place->load(['category', 'fuels', 'facilities']);

            return response()->json([
                'success' => true,
                'message' => 'Place created successfully',
                'data'    => new PlaceResource($place),
            ], 201);
        } catch (Throwable $e) {
            Log::error('Place store failed: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to create place',
                'error'   => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * PUT/PATCH /api/places/{id}
     */
    public function update(UpdatePlaceRequest $request, $id)
    {
        $place = Place::find($id);

        if (!$place) {
            return response()->json([
                'success' => false,
                'message' => 'Place not found',
            ], 404);
        }

        $data = $request->validated();

        try {
            $place = DB::transaction(function () use ($place, $data) {
                // 1. Update place fields (only fillable provided)
                $place->update(array_filter([
                    'category_id'   => $data['category_id']   ?? null,
                    'name'          => $data['name']          ?? null,
                    'address'       => $data['address']       ?? null,
                    'latitude'      => $data['latitude']      ?? null,
                    'longitude'     => $data['longitude']     ?? null,
                    'description'   => $data['description']   ?? null,
                    'rating'        => $data['rating']        ?? null,
                    'photo_url'     => $data['photo_url']     ?? null,
                    'opening_hours' => $data['opening_hours'] ?? null,
                ], fn ($v) => !is_null($v)));

                // 2. Sync facilities if provided (replace all)
                if (array_key_exists('facility_ids', $data)) {
                    $place->facilities()->sync($data['facility_ids'] ?? []);
                }

                // 3. Sync fuels if provided (replace all)
                if (array_key_exists('fuels', $data)) {
                    $fuelSync = [];
                    foreach (($data['fuels'] ?? []) as $fuel) {
                        $fuelSync[$fuel['id']] = [
                            'price'        => $fuel['price'],
                            'is_available' => (bool) $fuel['is_available'],
                        ];
                    }
                    $place->fuels()->sync($fuelSync);
                }

                return $place;
            });

            $place->load(['category', 'fuels', 'facilities']);

            return response()->json([
                'success' => true,
                'message' => 'Place updated successfully',
                'data'    => new PlaceResource($place),
            ], 200);
        } catch (Throwable $e) {
            Log::error('Place update failed: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to update place',
                'error'   => $e->getMessage(),
            ], 500);
        }
    }

    public function import(Request $request)
{
    $places = $request->all();

    if (!is_array($places)) {
        return response()->json([
            'success' => false,
            'message' => 'Request harus berupa array JSON'
        ], 400);
    }

    DB::beginTransaction();

    try {

        foreach ($places as $data) {

            $place = Place::create([
                'category_id'   => $data['category_id'],
                'name'          => $data['name'],
                'address'       => $data['address'],
                'latitude'      => $data['latitude'],
                'longitude'     => $data['longitude'],
                'description'   => $data['description'] ?? null,
                'rating'        => $data['rating'] ?? 0,
                'photo_url'     => $data['photo_url'] ?? null,
                'opening_hours' => $data['opening_hours'],
            ]);

            if (!empty($data['facility_ids'])) {
                $place->facilities()->sync($data['facility_ids']);
            }

            if (!empty($data['fuels'])) {

                $fuelSync = [];

                foreach ($data['fuels'] as $fuel) {
                    $fuelSync[$fuel['id']] = [
                        'price' => $fuel['price'],
                        'is_available' => $fuel['is_available']
                    ];
                }

                $place->fuels()->sync($fuelSync);
            }
        }

        DB::commit();

        return response()->json([
            'success' => true,
            'message' => count($places) . ' data berhasil diimport'
        ]);

    } catch (\Exception $e) {

        DB::rollBack();

        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ],500);
    }
}

    /**
     * DELETE /api/places/{id}
     */
    public function destroy($id)
    {
        $place = Place::find($id);

        if (!$place) {
            return response()->json([
                'success' => false,
                'message' => 'Place not found',
            ], 404);
        }

        try {
            DB::transaction(function () use ($place) {
                // Detach pivot relations first
                $place->facilities()->detach();
                $place->fuels()->detach();

                // Delete the place
                $place->delete();
            });

            return response()->json([
                'success' => true,
                'message' => 'Place deleted successfully',
            ], 200);
        } catch (Throwable $e) {
            Log::error('Place destroy failed: ' . $e->getMessage(), [
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to delete place',
                'error'   => $e->getMessage(),
            ], 500);
        }
    }
}