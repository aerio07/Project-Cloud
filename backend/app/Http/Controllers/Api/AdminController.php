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

        // Optimized single query to fetch all counts in one roundtrip to Supabase
        $stats = \Illuminate\Support\Facades\DB::select("
            SELECT 
                (SELECT COUNT(*) FROM places) as total_places,
                (SELECT COUNT(*) FROM users WHERE role = 'user') as total_users,
                (SELECT COUNT(*) FROM reviews) as total_reviews,
                (SELECT COUNT(*) FROM fuels) as total_fuels,
                (SELECT COUNT(*) FROM categories) as total_categories,
                (SELECT COUNT(*) FROM facilities) as total_facilities
        ")[0];

        return response()->json([
            'success' => true,
            'data' => [
                'total_places' => (int)$stats->total_places,
                'total_users' => (int)$stats->total_users,
                'total_reviews' => (int)$stats->total_reviews,
                'total_fuels' => (int)$stats->total_fuels,
                'total_categories' => (int)$stats->total_categories,
                'total_facilities' => (int)$stats->total_facilities,
            ]
        ]);
    }

    public function formOptions(Request $request)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        return response()->json([
            'success' => true,
            'data' => [
                'categories' => Category::orderBy('name')->get(),
                'facilities' => Facility::orderBy('name')->get(),
                'fuels' => Fuel::orderBy('name')->get(),
            ]
        ]);
    }

    // ==============================
    // CRUD PLACES (SPBU)
    // ==============================

    public function indexPlaces(Request $request)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $places = Place::with(['category', 'fuels', 'facilities', 'images'])->orderBy('name')->get();

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
            'photos' => 'nullable|array',
            'photos.*' => 'image|mimes:jpeg,png,jpg,webp|max:5120',
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

        $uploadedPhotoUrls = [];
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $photoFile) {
                $path = $photoFile->store('places', 'public');
                $uploadedPhotoUrls[] = '/storage/' . $path;
            }
            if (!empty($uploadedPhotoUrls)) {
                $data['photo_url'] = $uploadedPhotoUrls[0];
            }
        } elseif ($request->hasFile('photo')) {
            $path = $request->file('photo')->store('places', 'public');
            $photoUrl = '/storage/' . $path;
            $data['photo_url'] = $photoUrl;
            $uploadedPhotoUrls[] = $photoUrl;
        }

        $place = Place::create($data);

        foreach ($uploadedPhotoUrls as $photoUrl) {
            $place->images()->create(['photo_url' => $photoUrl]);
        }

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
            'data' => $place->load(['category', 'fuels', 'facilities', 'images']),
        ], 201);
    }

    public function updatePlace(Request $request, $id)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $place = Place::with('images')->find($id);
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
            'photos' => 'nullable|array',
            'photos.*' => 'image|mimes:jpeg,png,jpg,webp|max:5120',
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
        $uploadedPhotoUrls = [];
        $hasNewPhotos = $request->hasFile('photos') || $request->hasFile('photo');

        if ($hasNewPhotos) {
            // Hapus gambar-gambar lama dari storage
            foreach ($place->images as $img) {
                $oldPath = str_replace('/storage/', '', $img->photo_url);
                Storage::disk('public')->delete($oldPath);
            }
            if ($place->photo_url) {
                $oldPath = str_replace('/storage/', '', $place->photo_url);
                Storage::disk('public')->delete($oldPath);
            }

            // Hapus record gambar lama
            $place->images()->delete();

            if ($request->hasFile('photos')) {
                foreach ($request->file('photos') as $photoFile) {
                    $path = $photoFile->store('places', 'public');
                    $uploadedPhotoUrls[] = '/storage/' . $path;
                }
                if (!empty($uploadedPhotoUrls)) {
                    $data['photo_url'] = $uploadedPhotoUrls[0];
                }
            } elseif ($request->hasFile('photo')) {
                $path = $request->file('photo')->store('places', 'public');
                $photoUrl = '/storage/' . $path;
                $data['photo_url'] = $photoUrl;
                $uploadedPhotoUrls[] = $photoUrl;
            }
        }

        $place->update($data);

        if ($hasNewPhotos) {
            foreach ($uploadedPhotoUrls as $photoUrl) {
                $place->images()->create(['photo_url' => $photoUrl]);
            }
        }

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
            'data' => $place->load(['category', 'fuels', 'facilities', 'images']),
        ]);
    }

    public function destroyPlace(Request $request, $id)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $place = Place::with('images')->find($id);
        if (!$place) {
            return response()->json(['success' => false, 'message' => 'SPBU tidak ditemukan.'], 404);
        }

        // Hapus file-file gambar lama dari storage
        foreach ($place->images as $img) {
            $oldPath = str_replace('/storage/', '', $img->photo_url);
            Storage::disk('public')->delete($oldPath);
        }
        if ($place->photo_url) {
            $oldPath = str_replace('/storage/', '', $place->photo_url);
            Storage::disk('public')->delete($oldPath);
        }

        $place->images()->delete();
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

    public function destroyCategory(Request $request, $id)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $category = Category::find($id);
        if (!$category) {
            return response()->json(['success' => false, 'message' => 'Kategori tidak ditemukan.'], 404);
        }

        try {
            $category->delete();
            return response()->json([
                'success' => true,
                'message' => 'Kategori berhasil dihapus.',
            ]);
        } catch (\Illuminate\Database\QueryException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori tidak dapat dihapus karena masih digunakan oleh beberapa SPBU.',
            ], 400);
        }
    }

    public function destroyFacility(Request $request, $id)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $facility = Facility::find($id);
        if (!$facility) {
            return response()->json(['success' => false, 'message' => 'Fasilitas tidak ditemukan.'], 404);
        }

        try {
            $facility->delete();
            return response()->json([
                'success' => true,
                'message' => 'Fasilitas berhasil dihapus.',
            ]);
        } catch (\Illuminate\Database\QueryException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Fasilitas tidak dapat dihapus karena masih digunakan.',
            ], 400);
        }
    }

    public function destroyFuel(Request $request, $id)
    {
        if (!$this->getAdminUser($request)) return $this->unauthorizedResponse();

        $fuel = Fuel::find($id);
        if (!$fuel) {
            return response()->json(['success' => false, 'message' => 'Jenis BBM tidak ditemukan.'], 404);
        }

        try {
            $fuel->delete();
            return response()->json([
                'success' => true,
                'message' => 'Jenis BBM berhasil dihapus.',
            ]);
        } catch (\Illuminate\Database\QueryException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Jenis BBM tidak dapat dihapus karena masih digunakan.',
            ], 400);
        }
    }
}
