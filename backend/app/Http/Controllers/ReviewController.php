<?php

namespace App\Http\Controllers;

use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ReviewController extends Controller
{
    public function index()
    {
        $reviews = Review::with([
            'user',
            'room',
            'room.hotel',
            'bookingDetail',
        ])->get();

        if ($reviews->isEmpty()) {
            return response()->json([
                'message' => 'Belum ada data review',
            ], 404);
        }

        return response()->json($reviews);
    }

    public function roomReviews($roomId)
    {
        $reviews = Review::with([
            'user',
            'room',
            'room.hotel',
            'bookingDetail',
        ])
            ->where('room_id', $roomId)
            ->get();

        if ($reviews->isEmpty()) {
            return response()->json([
                'message' => 'Belum ada data review',
            ], 404);
        }

        return response()->json($reviews);
    }

    public function hotelReviews($hotelId)
    {
        $reviews = Review::with([
            'user',
            'room',
            'room.hotel',
            'bookingDetail',
        ])
            ->whereHas('room.hotel', function ($query) use ($hotelId) {
                $query->where('hotel_id', $hotelId);
            })
            ->get();

        if ($reviews->isEmpty()) {
            return response()->json([
                'message' => 'Belum ada data review',
            ], 404);
        }

        return response()->json($reviews);
    }

    public function show($id)
    {
        $review = Review::with([
            'user',
            'room',
            'room.hotel',
            'bookingDetail',
        ])->find($id);

        if (! $review) {
            return response()->json([
                'message' => 'Tidak ada review yang sesuai',
            ], 404);
        }

        return response()->json($review);
    }

    public function userReviews($userId)
    {
        $reviews = Review::with([
            'room.hotel',
        ])
            ->where('user_id', $userId)
            ->get();
        if ($reviews->isEmpty()) {
            return response()->json([
                'message' => 'User belum memiliki review',
            ], 404);
        }

        return response()->json($reviews);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'room_id'           => 'required|exists:rooms,id',
            'booking_detail_id' => 'required|exists:booking_details,id',
            'rating'            => 'required|integer|min:1|max:5',
            'description'       => 'required|string',
            'created_at'        => 'required|date',
            'image'             => 'nullable|image|mimes:jpg,jpeg,png|max:20480',
        ]);

        $validated['user_id'] = Auth::user()->id;

        if ($request->hasFile('image')) {
            $validated['image'] = $request->file('image')->store('reviews', 'public');
        }
        $review = Review::create($validated);

        return response()->json([
            'message' => 'Review berhasil dibuat',
            'review' => [
                ...$review->toArray(),
                'image_url' => $review->image_url,
            ]
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $review = Review::find($id);
        if (! $review) {
            return response()->json([
                'message' => 'Data review tidak ditemukan',
            ], 404);
        }
        $validated = $request->validate([
            'room_id'           => 'exists:rooms,id',
            'booking_detail_id' => 'exists:booking_details,id',
            'rating' => 'integer|min:1|max:5',
            'description' => 'string',
            'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
        ]);

        $validated['user_id'] = Auth::user()->id;

        if ($request->hasFile('image')) {
            $validated['image'] = $request->file('image')->store('reviews', 'public');
        }
        $review->update($validated);

        return response()->json([
            'message' => 'Data review berhasil diperbarui',
            'review' => $review,
        ]);
    }

    public function destroy($id)
    {
        $review = Review::find($id);
        if (! $review) {
            return response()->json([
                'message' => 'Data review tidak ditemukan',
            ], 404);
        }
        $review->delete();

        return response()->json([
            'message' => 'Data review berhasil dihapus',
        ]);
    }
}
