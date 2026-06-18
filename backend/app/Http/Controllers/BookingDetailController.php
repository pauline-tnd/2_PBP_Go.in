<?php

namespace App\Http\Controllers;

use App\Http\Controllers\BookingController;
use App\Models\BookingDetail;
use App\Models\Room;
use Illuminate\Http\Request;

class BookingDetailController extends Controller
{
    public function index()
    {
        $details = BookingDetail::with(['booking.user', 'room', 'addOns.addOn'])->get();
        if ($details->isEmpty()) {
            return response()->json([
                'message' => 'Data Booking Detail tidak ditemukan',
                'data' => []
            ], 404);
        }
        return response()->json([
            'message' => 'Data Booking Detail ditemukan',
            'data' => $details
        ]);
    }

    public function show($id)
    {
        $detail = BookingDetail::with(['booking.user', 'room', 'addOns.addOn'])->find($id);
        if (!$detail) {
            return response()->json([
                'message' => 'Booking Detail tidak ditemukan'
            ], 404);
        }
        return response()->json([
            'message' => 'Booking Detail ditemukan',
            'data' => $detail
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'booking_id' => 'required|exists:bookings,id',
            'room_id' => 'required|exists:rooms,id',
            'total_room' => 'required|integer|min:1',
            'notes' => 'nullable|string'
        ]);
        
        $room = Room::find($validated['room_id']);
        $validated['sub_total'] = $room->price * $validated['total_room'];

        $detail = BookingDetail::create($validated);

        BookingController::calculateTotal($detail->booking_id);

        return response()->json([
            'message' => 'Booking Detail Created',
            'detail' => $detail
        ], 201);

    }

    public function update(Request $request, $id)
    {
        $detail = BookingDetail::find($id);
        if (!$detail) {
            return response()->json([
                'message' => 'Booking Detail tidak ditemukan'
            ], 404);
        }
        $validated = $request->validate([
            'booking_id' => 'exists:bookings,id',
            'room_id' => 'exists:rooms,id',
            'total_room' => 'integer|min:1',
            'notes' => 'nullable|string'
        ]);
        
        $pricingChanged = array_key_exists('total_room', $validated)
            || array_key_exists('room_id', $validated);

        $detail->update($validated);

        if ($pricingChanged) {
            BookingController::calculateTotal($detail->booking_id);
        }

        return response()->json([
            'message' => 'Booking Detail Updated',
            'detail' => $detail->fresh()
        ]);

    }

    public function destroy($id)
    {
        $detail = BookingDetail::find($id);
        if (!$detail) {
            return response()->json([
                'message' => 'Booking Detail tidak ditemukan'
            ], 404);
        }
        $bookingId = $detail->booking_id;
        $detail->delete();

        BookingController::calculateTotal($bookingId);

        return response()->json([
            'message' => 'Booking Detail berhasil dihapus'
        ]);

    }
}
