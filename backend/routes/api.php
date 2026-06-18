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
    UserController,
    AddOnController
};

// Public Route
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/google-login', [AuthController::class, 'googleLogin']);
Route::prefix('mobile-auth')->group(function () {
    Route::get('/ping', fn () => response()->json(['message' => 'ok'], 200));
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/google-login', [AuthController::class, 'googleLogin']);
});

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

    Route::apiResource('add-ons', AddOnController::class)->only(['index']);
    
    // Read Room (nested)
    Route::apiResource('rooms', RoomController::class)
        ->only(['index', 'show']);
        // GET /rooms/{room}
    
    // Wishlist
    Route::apiResource('wishlists', WishlistController::class)
        ->only(['index', 'store', 'destroy']);
    
    // Bookings
    Route::apiResource('bookings', BookingController::class);
    Route::get('/bookings/{id}/review-details', [BookingController::class, 'reviewDetails']);
    Route::post('bookings/full', [BookingController::class, 'storeFull']);


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

});
