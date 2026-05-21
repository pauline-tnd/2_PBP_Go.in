<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\{
    Auth\AuthController,
    HotelController,
    RoomController,
    BookingController,
    BookingDetailController,
    BookingDetailAddOnController,
    ReviewController,
    WishlistController,
    UserController
};

// Public Route
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/google-login', [AuthController::class, 'googleLogin']);

// Protected Route
Route::middleware('auth:sanctum')->group(function () {
    // Logout
    Route::post('/logout', [AuthController::class, 'logout']);

    // User Profile
    Route::prefix('user')->group(function () {
        Route::get('/', [UserController::class, 'show']);
        Route::put('/', [UserController::class, 'update']);
        Route::put('/password', [UserController::class, 'updatePassword']);
        Route::put('/profile', [UserController::class, 'updateProfile']);
        Route::delete('/', [UserController::class, 'destroy']);
    });

    // Read Hotel
    Route::apiResource('hotels', HotelController::class)
        ->only(['index', 'show']);
    
    // Read Room (nested)
    Route::apiResource('rooms', RoomController::class)
        ->only(['index', 'show']);
        // GET /rooms/{room}
    
    // Wishlist
    Route::apiResource('wishlists', WishlistController::class)
        ->only(['index', 'store', 'destroy']);
    
    // Bookings
    Route::apiResource('bookings', BookingController::class);
    // Route::get('users/{user}/bookings', [BookingController::class, 'userBookings']);


    // Booking Details
    Route::apiResource('booking-details', BookingDetailController::class);


    // Booking Detail Addons
    Route::apiResource('booking-detail-addons', BookingDetailAddOnController::class);
    Route::get(
        'booking-details/{bookingDetail}/addons',
        [BookingDetailAddOnController::class, 'getByBookingDetail']
    );

    // Reviews
    Route::apiResource('reviews', ReviewController::class);
    Route::get('hotels/{hotel}/reviews', [ReviewController::class, 'hotelReviews']);
    Route::get('rooms/{room}/reviews', [ReviewController::class, 'roomReviews']);
    Route::get('users/{user}/reviews', [ReviewController::class, 'userReviews']);


    // apiResource :
    // GET    /resource
    // POST   /resource
    // GET    /resource/{id}
    // PUT    /resource/{id}
    // DELETE /resource/{id}

    // Route::prefix('bookings')->group(function () {
    //     Route::get('/', [BookingController::class, 'index']);
    //     Route::get('/{id}', [BookingController::class, 'show']);
    //     Route::get('/user/{userId}', [BookingController::class, 'userBookings']);
    //     Route::post('/store', [BookingController::class, 'store']);
    //     Route::put('/update/{id}', [BookingController::class, 'update']);
    //     Route::delete('/destroy/{id}', [BookingController::class, 'destroy']);
    // });
    
    // // Route::apiResource('booking-details', BookingDetailController::class);
    // Route::prefix('booking-details')->group(function () {
    //     Route::get('/', [BookingDetailController::class, 'index']);
    //     Route::get('/{id}', [BookingDetailController::class, 'show']);
    //     Route::post('/store', [BookingDetailController::class, 'store']);
    //     Route::put('/update/{id}', [BookingDetailController::class, 'update']);
    //     Route::delete('/destroy/{id}', [BookingDetailController::class, 'destroy']);
    // });
    
    // Route::prefix('booking-detail-addons')->group(function () {
    //     Route::get('/', [BookingDetailAddOnController::class, 'index']);
    //     Route::get('/{id}', [BookingDetailAddOnController::class, 'show']);
    //     Route::get('/booking-detail/{bookingDetailId}', [BookingDetailAddOnController::class, 'getByBookingDetail']);
    //     Route::post('/store', [BookingDetailAddOnController::class, 'store']);
    //     Route::put('/update/{id}', [BookingDetailAddOnController::class, 'update']);
    //     Route::delete('/destroy/{id}', [BookingDetailAddOnController::class, 'destroy']);
    // });
    
    // Route::prefix('reviews')->group(function () {
    //     Route::get('/', [ReviewController::class, 'index']);
    //     Route::get('/{id}', [ReviewController::class, 'show']);
    //     Route::get('/user/{userId}', [ReviewController::class, 'userReviews']);
    //     Route::post('/store', [ReviewController::class, 'store']);
    //     Route::put('/update/{id}', [ReviewController::class, 'update']);
    //     Route::delete('/destroy/{id}', [ReviewController::class, 'destroy']);
    // });
});
