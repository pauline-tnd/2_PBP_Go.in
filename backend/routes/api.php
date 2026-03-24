<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\{
    HotelController,
    RoomController,
};

// Read Hotel
Route::apiResource('hotels', HotelController::class)
    ->only(['index', 'show']);

// Read Room (nested)
Route::apiResource('hotels.rooms', RoomController::class)
    ->only(['index', 'show']);
    // GET /hotels/{hotel}/rooms/{room}