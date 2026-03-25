<?php

namespace App\Http\Controllers;

use App\Models\BookingDetail;
use Illuminate\Http\Request;

class BookingDetailController extends Controller
{
    public function index()
    {
        $details = BookingDetail::with(['booking.user', 'room', 'addOns.addOn'])->get();
        return response()->json($details);
    }

    public function show($id)
    {
        $detail = BookingDetail::with(['booking.user', 'room', 'addOns.addOn'])->findOrFail($id);
        return response()->json($detail);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'booking_id' => 'required|exists:bookings,book_id',
            'room_id' => 'required|exists:rooms,id',
            'total_room' => 'required|integer|min:1',
            'sub_total' => 'required|numeric|min:0',
            'notes' => 'nullable|string',
        ]);

        $detail = BookingDetail::create($validated);

        return response()->json([
            'message' => 'Booking Detail Created',
            'detail' => $detail
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $detail = BookingDetail::findOrFail($id);

        $validated = $request->validate([
            'total_room' => 'integer|min:1',
            'sub_total' => 'numeric|min:0',
            'notes' => 'nullable|string',
        ]);

        $detail->update($validated);

        return response()->json([
            'message' => 'Booking Detail Updated',
            'detail' => $detail
        ]);
    }

    public function destroy($id)
    {
        $detail = BookingDetail::findOrFail($id);
        $detail->delete();

        return response()->json([
            'message' => 'Booking Detail Deleted'
        ]);
    }
}