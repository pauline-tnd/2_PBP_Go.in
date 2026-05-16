<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Room;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class BookingController extends Controller
{
    public function index()
    {
        $userId = Auth::user()->id;
        
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

    public function show(Booking $booking)
    {
        $booking->load(['bookingDetails.room.hotel']);

        if (!$booking) {
            return response()->json([
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }
        return response()->json($booking);
    }

    // public function userBookings()
    // {
    //     $userId = Auth::user()->id;

    //     $bookings = Booking::with([
    //         'bookingDetails.room.hotel'
    //     ])
    //     ->where('user_id', $userId)
    //     ->get();
    //     if ($bookings->isEmpty()) {
    //         return response()->json([
    //             'message' => 'User belum memiliki booking'
    //         ], 404);
    //     }
    //     return response()->json($bookings);
    // }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'check_in' => 'required|date|after_or_equal:today',
            'check_out' => 'required|date|after:check_in',
            'total_price' => 'required|numeric|min:0',
            'status' => ['nullable', Rule::in(['paid','completed','cancelled'])],
        ]);
        
        $validated['user_id'] = Auth::user()->id;
        
        $validated['booking_number'] = 'BK-' . strtoupper(Str::random(8));
        $validated['status'] = $validated['status'] ?? 'pending';
        $booking = Booking::create($validated);
        return response()->json([
            'message' => 'Booking berhasil dibuat',
            'booking' => $booking
        ], 201);
    }

    public function update(Request $request, Booking $booking)
    {
        $validated = $request->validate([
            // 'check_in' => 'date',
            // 'check_out' => 'date|after:check_in',
            // 'total_price' => 'numeric|min:0',
            'status' => [Rule::in(['paid','completed','cancelled'])],
        ]);

        $validated['user_id'] = Auth::user()->id;

        $booking->update($validated);
        return response()->json([
            'message' => 'Booking berhasil diperbarui',
            'booking' => $booking
        ]);
    }

    public function destroy(Booking $booking)
    {
        if ($booking->user_id !== Auth::id()) {
            return response()->json([
                'message' => 'Anda tidak memiliki akses untuk menghapus booking ini'
            ], 403);
        }
        
        $booking->delete();
        return response()->json([
            'message' => 'Booking berhasil dihapus'
        ]);
    }
}
