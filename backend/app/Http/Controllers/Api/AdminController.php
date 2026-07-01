<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Place;
use App\Models\Fuel;
use App\Models\Category;
use App\Models\Facility;
use App\Models\User;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class AdminController extends Controller
{
    /**
     * Memverifikasi bahwa request berasal dari user admin.
     */
    private function getAdminUser(Request $request)
    {
        $token = $request->header('Authorization');
        if ($token && str_starts_with($token, 'Bearer ')) {
            $token = substr($token, 7);
        }

        if (!$token) return null;

        $user = User::where('api_token', $token)->first();
        return ($user && $user->isAdmin()) ? $user : null;
    }

    private function unauthorizedResponse()
    {
        return response()->json([
            'success' => false,
            'message' => 'Akses ditolak. Hanya admin yang diizinkan.'
        ], 403);
    }

    // ==============================
    // DASHBOARD
    // ==============================

    public function dashboard(Request $request)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        return response()->json([
            'success' => true,
            'data' => [
                'total_places' => Place::count(),
                'total_users' => User::where('role', 'user')->count(),
                'total_reviews' => Review::count(),
                'total_fuels' => Fuel::count(),
                'total_categories' => Category::count(),
                'total_facilities' => Facility::count(),
            ]
        ]);
    }

    // ==============================
    // CRUD PLACES (SPBU)
    // ==============================

    public function indexPlaces(Request $request)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $places = Place::with(['category', 'fuels', 'facilities'])->orderBy('name')->get();

        return response()->json([
            'success' => true,
            'data' => $places,
        ]);
    }

    public function storePlace(Request $request)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'address' => 'required|string',
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'category_id' => 'required|exists:categories,id',
            'description' => 'nullable|string',
            'opening_hours' => 'nullable|string',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:5120',
            'sync_facilities' => 'nullable|boolean',
            'facilities' => 'nullable|array',
            'facilities.*' => 'exists:facilities,id',
            'sync_fuels' => 'nullable|boolean',
            'fuels' => 'nullable|array',
            'fuels.*.fuel_id' => 'required|exists:fuels,id',
            'fuels.*.price' => 'nullable|numeric|min:0',
            'fuels.*.is_available' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->only(['name', 'address', 'latitude', 'longitude', 'category_id', 'description', 'opening_hours']);

        // Upload gambar
        if ($request->hasFile('photo')) {
            $path = $request->file('photo')->store('places', 'public');
            $data['photo_url'] = '/storage/' . $path;
        }

        $place = Place::create($data);

        // Attach fasilitas
        if ($request->boolean('sync_facilities') || $request->has('facilities')) {
            $place->facilities()->sync($request->facilities ?? []);
        }

        // Attach BBM dengan harga per SPBU
        if ($request->boolean('sync_fuels') || $request->has('fuels')) {
            $fuelData = [];
            foreach ($request->fuels ?? [] as $fuel) {
                $fuelData[$fuel['fuel_id']] = [
                    'price' => $fuel['price'] ?? null,
                    'is_available' => $fuel['is_available'] ?? true,
                ];
            }
            $place->fuels()->sync($fuelData);
        }

        return response()->json([
            'success' => true,
            'message' => 'SPBU berhasil ditambahkan.',
            'data' => $place->load(['category', 'fuels', 'facilities']),
        ], 201);
    }

    public function updatePlace(Request $request, $id)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $place = Place::find($id);
        if (!$place) {
            return response()->json(['success' => false, 'message' => 'SPBU tidak ditemukan.'], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'address' => 'sometimes|required|string',
            'latitude' => 'sometimes|required|numeric',
            'longitude' => 'sometimes|required|numeric',
            'category_id' => 'sometimes|required|exists:categories,id',
            'description' => 'nullable|string',
            'opening_hours' => 'nullable|string',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:5120',
            'sync_facilities' => 'nullable|boolean',
            'facilities' => 'nullable|array',
            'facilities.*' => 'exists:facilities,id',
            'sync_fuels' => 'nullable|boolean',
            'fuels' => 'nullable|array',
            'fuels.*.fuel_id' => 'required|exists:fuels,id',
            'fuels.*.price' => 'nullable|numeric|min:0',
            'fuels.*.is_available' => 'nullable|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->only(['name', 'address', 'latitude', 'longitude', 'category_id', 'description', 'opening_hours']);

        // Upload gambar baru (hapus lama jika ada)
        if ($request->hasFile('photo')) {
            // Hapus gambar lama
            if ($place->photo_url) {
                $oldPath = str_replace('/storage/', '', $place->photo_url);
                Storage::disk('public')->delete($oldPath);
            }
            $path = $request->file('photo')->store('places', 'public');
            $data['photo_url'] = '/storage/' . $path;
        }

        $place->update($data);

        // Update fasilitas
        if ($request->boolean('sync_facilities') || $request->has('facilities')) {
            $place->facilities()->sync($request->facilities ?? []);
        }

        // Update BBM
        if ($request->boolean('sync_fuels') || $request->has('fuels')) {
            $fuelData = [];
            foreach ($request->fuels ?? [] as $fuel) {
                $fuelData[$fuel['fuel_id']] = [
                    'price' => $fuel['price'] ?? null,
                    'is_available' => $fuel['is_available'] ?? true,
                ];
            }
            $place->fuels()->sync($fuelData);
        }

        return response()->json([
            'success' => true,
            'message' => 'SPBU berhasil diperbarui.',
            'data' => $place->load(['category', 'fuels', 'facilities']),
        ]);
    }

    public function destroyPlace(Request $request, $id)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $place = Place::find($id);
        if (!$place) {
            return response()->json(['success' => false, 'message' => 'SPBU tidak ditemukan.'], 404);
        }

        // Hapus gambar
        if ($place->photo_url) {
            $oldPath = str_replace('/storage/', '', $place->photo_url);
            Storage::disk('public')->delete($oldPath);
        }

        $place->delete();

        return response()->json([
            'success' => true,
            'message' => 'SPBU berhasil dihapus.',
        ]);
    }

    // ==============================
    // FUELS (BBM)
    // ==============================

    public function indexFuels(Request $request)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        return response()->json([
            'success' => true,
            'data' => Fuel::orderBy('brand')->orderBy('name')->get(),
        ]);
    }

    public function storeFuel(Request $request)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $validator = Validator::make($request->all(), [
            'brand' => 'nullable|string|max:100',
            'name' => 'required|string|max:255',
            'octane' => 'nullable|string|max:50',
            'national_price' => 'required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $fuel = Fuel::create($request->only(['brand', 'name', 'octane', 'national_price']));

        return response()->json([
            'success' => true,
            'message' => 'BBM berhasil ditambahkan.',
            'data' => $fuel,
        ], 201);
    }

    public function updateFuel(Request $request, $id)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $fuel = Fuel::find($id);
        if (!$fuel) {
            return response()->json(['success' => false, 'message' => 'BBM tidak ditemukan.'], 404);
        }

        $validator = Validator::make($request->all(), [
            'brand' => 'nullable|string|max:100',
            'name' => 'sometimes|required|string|max:255',
            'octane' => 'nullable|string|max:50',
            'national_price' => 'sometimes|required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $fuel->update($request->only(['brand', 'name', 'octane', 'national_price']));

        return response()->json([
            'success' => true,
            'message' => 'Harga BBM berhasil diperbarui.',
            'data' => $fuel,
        ]);
    }

    // ==============================
    // CATEGORIES
    // ==============================

    public function indexCategories(Request $request)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        return response()->json([
            'success' => true,
            'data' => Category::orderBy('name')->get(),
        ]);
    }

    public function storeCategory(Request $request)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'icon' => 'nullable|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $category = Category::create($request->only(['name', 'icon']));

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil ditambahkan.',
            'data' => $category,
        ], 201);
    }

    public function updateCategory(Request $request, $id)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $category = Category::find($id);
        if (!$category) {
            return response()->json(['success' => false, 'message' => 'Kategori tidak ditemukan.'], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'icon' => 'nullable|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $category->update($request->only(['name', 'icon']));

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil diperbarui.',
            'data' => $category,
        ]);
    }

    // ==============================
    // FACILITIES
    // ==============================

    public function indexFacilities(Request $request)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        return response()->json([
            'success' => true,
            'data' => Facility::orderBy('name')->get(),
        ]);
    }

    public function storeFacility(Request $request)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'icon' => 'nullable|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $facility = Facility::create($request->only(['name', 'icon']));

        return response()->json([
            'success' => true,
            'message' => 'Fasilitas berhasil ditambahkan.',
            'data' => $facility,
        ], 201);
    }

    public function updateFacility(Request $request, $id)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $facility = Facility::find($id);
        if (!$facility) {
            return response()->json(['success' => false, 'message' => 'Fasilitas tidak ditemukan.'], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'icon' => 'nullable|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $facility->update($request->only(['name', 'icon']));

        return response()->json([
            'success' => true,
            'message' => 'Fasilitas berhasil diperbarui.',
            'data' => $facility,
        ]);
    }
}
