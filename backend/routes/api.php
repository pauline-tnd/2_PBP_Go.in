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
    Route::post('/', [BookingController::class, 'store']);
    Route::put('/{id}', [BookingController::class, 'update']);
    Route::delete('/{id}', [BookingController::class, 'destroy']);
});

Route::prefix('booking-details')->group(function () {
    Route::get('/', [BookingDetailController::class, 'index']);           // semua detail
    Route::get('/{id}', [BookingDetailController::class, 'show']);       // detail tertentu
    Route::post('/', [BookingDetailController::class, 'store']);          // tambah detail
    Route::put('/{id}', [BookingDetailController::class, 'update']);     // update detail
    Route::delete('/{id}', [BookingDetailController::class, 'destroy']); // hapus detail
});

Route::prefix('booking-detail-addons')->group(function () {
    Route::get('/', [BookingDetailAddOnController::class, 'index']);                     // semua add-on
    Route::get('/{id}', [BookingDetailAddOnController::class, 'show']);                 // detail add-on
    Route::get('/booking-detail/{bookingDetailId}', [BookingDetailAddOnController::class, 'getByBookingDetail']); // add-on per detail
    Route::post('/', [BookingDetailAddOnController::class, 'store']);                    // tambah add-on
    Route::put('/{id}', [BookingDetailAddOnController::class, 'update']);               // update add-on
    Route::delete('/{id}', [BookingDetailAddOnController::class, 'destroy']);           // hapus add-on
});