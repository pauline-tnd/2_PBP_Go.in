<?php

namespace App\Http\Controllers;

use App\Models\BookingDetail;
use Illuminate\Http\Request;

class BookingDetailController extends Controller
{
    public function index()
    {
        $details = BookingDetail::with(['booking.user', 'room', 'addOns.addOn'])->get();
        if ($details->isEmpty()) {
            return response()->json([
                'message' => 'Data Booking Detail tidak ditemukan',
                'data' => [],
            ], 404);
        }

        return response()->json([
            'message' => 'Data Booking Detail ditemukan',
            'data' => $details,
        ]);
    }

    public function show($id)
    {
        $detail = BookingDetail::with(['booking.user', 'room', 'addOns.addOn'])->find($id);
        if (! $detail) {
            return response()->json([
                'message' => 'Booking Detail tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'message' => 'Booking Detail ditemukan',
            'data' => $detail,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'booking_id' => 'required|exists:bookings,id',
            'room_id' => 'required|exists:rooms,id',
            'total_room' => 'required|integer|min:1',
            'sub_total' => 'required|numeric|min:0',
            'notes' => 'nullable|string',
        ]);
        $detail = BookingDetail::create($validated);

        return response()->json([
            'message' => 'Booking Detail Created',
            'detail' => $detail,
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $detail = BookingDetail::find($id);
        if (! $detail) {
            return response()->json([
                'message' => 'Booking Detail tidak ditemukan',
            ], 404);
        }
        $validated = $request->validate([
            'booking_id' => 'exists:bookings,id',
            'room_id' => 'exists:rooms,id',
            'total_room' => 'integer|min:1',
            'sub_total' => 'numeric|min:0',
            'notes' => 'nullable|string',
        ]);
        $detail->update($validated);

        return response()->json([
            'message' => 'Booking Detail Updated',
            'detail' => $detail,
        ]);
    }

    public function destroy($id)
    {
        $detail = BookingDetail::find($id);
        if (! $detail) {
            return response()->json([
                'message' => 'Booking Detail tidak ditemukan',
            ], 404);
        }
        $detail->delete();

        return response()->json([
            'message' => 'Booking Detail berhasil dihapus',
        ]);
    }
}
