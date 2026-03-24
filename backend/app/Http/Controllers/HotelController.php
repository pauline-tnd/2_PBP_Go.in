<?php

namespace App\Http\Controllers;

use App\Models\Hotel;
use Illuminate\Http\Request;
use Illuminate\Support\Optional;

class HotelController extends Controller
{
    public function index(Request $request) // all hotel
    {
        $query = Hotel::with([
            'hotelImage',
        ])
            ->withMin('rooms as start_from_price', 'price')                          // start from price
            ->withAvg('reviews as hotel_rating', 'rating')   // table reviews, column rating
            ->withCount('bookings as total_bookings');       // total booking for popularity

        // When = Optional
        // Search by hotel name
        $query->when($request->search, function ($q, $search) {
            $q->where('name', 'like', '%' . $search . '%');
        });

        // Filter Price Range
        $query->when($request->min_price, function ($q, $min_price) {
            $q->whereHas('rooms', fn($room) => $room->where('price', '>=', $min_price));
        });
        $query->when($request->max_price, function ($q, $max_price) {
            $q->whereHas('rooms', fn($room) => $room->where('price', '<=', $max_price));
        });

        // Filtering hotel star
        $query->when($request->star, function ($q, $star) {
            // example star: ?star[]=4&star[]=5
            $q->whereIn('star', $star);
        });

        // // Filtering hotel minimum rating
        // $query->when($request->min_rating, function ($q, $min_rating) {
        //     $q->having('hotel_rating', '>=', $min_rating);
        // });

        // Filtering hotel by list ID facilities, example: ?amenities[]=1&amenities[]=3
        $query->when($request->amenities, function ($q, $amenities) {
            $q->whereHas('hotelFacilities', fn($facility) => $facility->whereIn('id', $amenities));
        });

        // Sorting
        $sortBy = $request->input('sort_by', 'none');

        if ($sortBy === 'price_high_low') { // price desc
            $query->orderBy('start_from_price', 'desc');
        } elseif ($sortBy === 'price_low_high') { // price asc
            $query->orderBy('start_from_price', 'asc');
        } elseif ($sortBy === 'rating_high_low') { // hotel rate desc
            $query->orderBy('hotel_rating', 'desc');
        } elseif ($sortBy === 'popularity') { // total booking desc
            $query->orderBy('total_bookings', 'desc');
        } elseif ($sortBy === 'distance' && $request->user_lat && $request->user_lng) {
            // The Haversine formula calculates the shortest distance (great-circle distance)
            // between two points on a sphere, such as Earth, using their latitude and longitude.

            $lat = $request->user_lat;
            $lng = $request->user_lng;

            // select raw = inject raw, plain SQL statements
            // 6371 = earth's radius in kilometer (Km unit)
            // radians = convert degrees to radians
            $query->selectRaw("hotels.*, 
            (6371 * acos(
            cos( radians(?) ) 
            * cos( radians( latitude ) ) 
            * cos( radians( longitude ) - radians(?) ) + 
            sin( radians(?) ) 
            * sin( radians( latitude ) ) ) 
            ) AS distance", [$lat, $lng, $lat])
                ->orderBy('distance', 'asc'); // shortest distance
        } else {
            // Default sort
            $query->orderBy('id', 'desc');
        }

        // Execution : Pagination, load every 10 data
        $hotels = $query->cursorPaginate(10);

        return response()->json([
            'data' => $hotels,
        ], 200);
    }

    public function show(string $id) // hotel detail
    {
        $hotel = Hotel::with([
            'hotelImages',
            'hotelFacilities.icon', // facilities and icon

            // room list
            'rooms.roomImages',
            'rooms.roomFacilities',
        ])
            ->withAvg('rooms.reviews as hotel_rating', 'rating')   // hotel's average rating
            ->withCount('rooms.reviews as total_reviews')           // review total
            ->find($id);

        if (!$hotel) { // invalid id
            return response()->json([
                'message' => 'Hotel not found',
            ], 404);
        }

        return response()->json([ // success
            'data' => $hotel
        ], 200);
    }
}
