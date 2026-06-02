<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\PlaceController;
use App\Http\Controllers\Api\ReviewController;

Route::get('/categories', [CategoryController::class, 'index']);

Route::get('/places', [PlaceController::class, 'index']);

Route::get('/places/{id}', [PlaceController::class, 'show']);

Route::get('/reviews', [ReviewController::class, 'index']);

