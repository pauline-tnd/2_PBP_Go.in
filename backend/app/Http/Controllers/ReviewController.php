<?php

namespace App\Http\Controllers;

use App\Models\Review;
use App\Models\User;
use App\Models\BookingDetail;
use App\Models\Room;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ReviewController extends Controller
{
    public function index()
    {
        $bookings = Booking::with([
            'user',
            'bookingDetails.room.hotel'
        ])->get();
        if ($bookings->isEmpty()) {
            return response()->json([
                'message' => 'Belum ada data booking'
            ], 404);
        }
        return response()->json($bookings);
    }

    public function show($id)
    {
        $booking = Booking::with([
            'user',
            'bookingDetails.room.hotel'
        ])->find($id);
        if (!$booking) {
            return response()->json([
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }
        return response()->json($booking);
    }

    public function userBookings($userId)
    {
        $bookings = Booking::with([
            'bookingDetails.room.hotel'
        ])
        ->where('user_id', $userId)
        ->get();
        if ($bookings->isEmpty()) {
            return response()->json([
                'message' => 'User belum memiliki booking'
            ], 404);
        }
        return response()->json($bookings);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'check_in' => 'required|date',
            'check_out' => 'required|date|after:check_in',
            'total_price' => 'required|numeric|min:0',
            'status' => ['nullable', Rule::in(['pending','paid','completed','cancelled'])],
        ]);
        $validated['booking_number'] = 'BK-' . strtoupper(Str::random(8));
        $validated['status'] = $validated['status'] ?? 'pending';
        $booking = Booking::create($validated);
        return response()->json([
            'message' => 'Booking berhasil dibuat',
            'booking' => $booking
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $booking = Booking::find($id);
        if (!$booking) {
            return response()->json([
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }
        $validated = $request->validate([
            'user_id' => 'exists:users,id',
            'check_in' => 'date',
            'check_out' => 'date|after:check_in',
            'total_price' => 'numeric|min:0',
            'status' => [Rule::in(['pending','paid','completed','cancelled'])],
        ]);
        $booking->update($validated);
        return response()->json([
            'message' => 'Booking berhasil diperbarui',
            'booking' => $booking
        ]);
    }

    public function destroy($id)
    {
        $booking = Booking::find($id);
        if (!$booking) {
            return response()->json([
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }
        $booking->delete();
        return response()->json([
            'message' => 'Booking berhasil dihapus'
        ]);
    }
}
