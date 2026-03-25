<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\Room;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class BookingController extends Controller
{
    public function index()
    {
        $bookings = Booking::with(['user', 'room.hotel'])->get();
        return response()->json($bookings);
    }

    public function show($id)
    {
        $booking = Booking::with(['user', 'room.hotel'])->findOrFail($id);
        return response()->json($booking);
    }

    public function userBookings($userId)
    {
        $bookings = Booking::with('room.hotel')->where('user_id', $userId)->get();
        return response()->json($bookings);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
            'room_id' => 'required|exists:rooms,id',
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
        $booking = Booking::findOrFail($id);

        $validated = $request->validate([
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
        $booking = Booking::findOrFail($id);
        $booking->delete();

        return response()->json([
            'message' => 'Booking berhasil dihapus'
        ]);
    }
}