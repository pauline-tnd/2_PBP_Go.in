<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\{
    HotelController,
    RoomController,
    BookingController,
    BookingDetailController,
    BookingDetailAddOnController,
};

// Read Hotel
Route::apiResource('hotels', HotelController::class)
    ->only(['index', 'show']);

// Read Room (nested)
Route::apiResource('hotels.rooms', RoomController::class)
    ->only(['index', 'show']);
    // GET /hotels/{hotel}/rooms/{room}

Route::prefix('bookings')->group(function () {
    Route::get('/', [BookingController::class, 'index']);
    Route::get('/{id}', [BookingController::class, 'show']);
    Route::get('/user/{userId}', [BookingController::class, 'userBookings']);
    Route::post('/store', [BookingController::class, 'store']);
    Route::put('/update/{id}', [BookingController::class, 'update']);
    Route::delete('/destroy/{id}', [BookingController::class, 'destroy']);
});

Route::prefix('booking-details')->group(function () {
    Route::get('/', [BookingDetailController::class, 'index']);
    Route::get('/{id}', [BookingDetailController::class, 'show']);
    Route::post('/store', [BookingDetailController::class, 'store']);
    Route::put('/update/{id}', [BookingDetailController::class, 'update']);
    Route::delete('/destroy/{id}', [BookingDetailController::class, 'destroy']);
});

Route::prefix('booking-detail-addons')->group(function () {
    Route::get('/', [BookingDetailAddOnController::class, 'index']);
    Route::get('/{id}', [BookingDetailAddOnController::class, 'show']);
    Route::get('/booking-detail/{bookingDetailId}', [BookingDetailAddOnController::class, 'getByBookingDetail']);
    Route::post('/store', [BookingDetailAddOnController::class, 'store']);
    Route::put('/update/{id}', [BookingDetailAddOnController::class, 'update']);
    Route::delete('/destroy/{id}', [BookingDetailAddOnController::class, 'destroy']);
});