<?php

namespace App\Http\Controllers;

use App\Http\Controllers\BookingController;
use App\Models\BookingDetailAddOn;
use Illuminate\Http\Request;

class BookingDetailAddOnController extends Controller
{
    public function index()
    {
        $addons = BookingDetailAddOn::with(['bookingDetail.booking.user', 'addOn'])->get();

        return response()->json($addons);
    }

    public function show($id)
    {
        $addon = BookingDetailAddOn::with(['bookingDetail.booking.user', 'addOn'])->find($id);
        if (! $addon) {
            return response()->json([
                'message' => 'Data Booking Detail Add-On tidak ditemukan',
            ], 404);
        }

        return response()->json($addon);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'booking_detail_id' => 'required|exists:booking_details,id',
            'add_on_id' => 'required|exists:add_ons,id',
            'qty' => 'required|integer|min:1',
            'sub_total' => 'required|numeric|min:0',
        ]);
        $addon = BookingDetailAddOn::create($validated);
        $addon->load('bookingDetail');
        BookingController::calculateTotal($addon->bookingDetail->booking_id);
        return response()->json([
            'message' => 'Add-on berhasil ditambahkan ke booking detail',
            'addon' => $addon,
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $addon = BookingDetailAddOn::findOrFail($id);

        $validated = $request->validate([
            'qty' => 'integer|min:1',
            'sub_total' => 'numeric|min:0',
        ]);

        $addon->update($validated);
        $addon->load('bookingDetail');
        BookingController::calculateTotal($addon->bookingDetail->booking_id);

        return response()->json([
            'message' => 'Add-on booking detail berhasil diperbarui',
            'addon' => $addon,
        ]);
    }

    public function destroy($id)
    {
        $addon = BookingDetailAddOn::find($id);

        if (! $addon) {
            return response()->json([
                'message' => 'Data Booking Detail Add-On tidak ditemukan',
            ], 404);
        }

        $bookingId = $addon->bookingDetail->booking_id;
        $addon->delete();
        BookingController::calculateTotal($bookingId);

        return response()->json([
            'message' => 'Add-on booking detail berhasil dihapus',
        ]);
    }

    public function getByBookingDetail($bookingDetailId)
    {
        $addons = BookingDetailAddOn::with('addOn')
            ->where('booking_detail_id', $bookingDetailId)
            ->get();
        if ($addons->isEmpty()) {
            return response()->json([
                'message' => 'Add-on untuk Booking Detail ini tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'message' => 'Data add-on ditemukan',
            'data' => $addons,
        ]);
    }
}
