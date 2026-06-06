<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\BookingDetail;
use App\Models\Room;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Http;

class BookingController extends Controller
{
    public function index()
    {
        $userId = Auth::user()->id;

        $bookings = Booking::with([
            'bookingDetails.room.hotel',
            'bookingDetails.addOns.addOn',
            'bookingDetails.review'
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
        $booking->load([
            'bookingDetails.room.hotel',
            'bookingDetails.addOns.addOn',
        ]);

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
        // $subTotal = Booking::whereHas('bookingDetails');
        // $totalPrice = ;

        $validated = $request->validate([
            'check_in' => 'required|date|after_or_equal:today',
            'check_out' => 'required|date|after:check_in',
            'status' => ['required', Rule::in(['paid', 'completed', 'cancelled'])],
        ]);

        $validated['total_price'] = 0;


        $validated['user_id'] = Auth::user()->id;
        // $validated['status'] = $validated['status'] ?? 'paid';

        if ($validated['status'] != "cancelled") {
            $validated['booking_number'] = 'BK-' . strtoupper(Str::random(8));

            [$qrCode] = $this->generateQrCodes($validated['booking_number']);
            $validated['qr_code'] = $qrCode;
        }

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
            'status' => [Rule::in(['paid', 'completed', 'cancelled'])],
        ]);

        $validated['user_id'] = Auth::user()->id;

        $booking->update($validated);
        return response()->json([
            'message' => 'Booking berhasil diperbarui',
            'booking' => $booking
        ]);
    }

    public static function calculateTotal($bookingId)
    {
        $booking = Booking::with(['bookingDetails.room', 'bookingDetails.addOns.addOn'])->find($bookingId);
        if (!$booking) return;

        $checkIn = Carbon::parse($booking->check_in);
        $checkOut = Carbon::parse($booking->check_out);
        $duration = (int) $checkIn->diffInDays($checkOut);
        if ($duration <= 0) $duration = 1;

        $totalPrice = 0;

        foreach ($booking->bookingDetails as $detail) {
            $roomPrice = $detail->room->price ?? 0;
            $addOnPrice = 0;
            
            foreach ($detail->addOns as $detailAddOn) {
                $addOnPrice += ($detailAddOn->addOn->price ?? 0) * $detailAddOn->qty;
            }

            $subTotal = ($roomPrice + $addOnPrice) * $detail->total_room;
            BookingDetail::where('id', $detail->id)->update(['sub_total' => $subTotal]);

            $totalPrice += $subTotal;
        }

        $booking->total_price = $totalPrice * $duration;
        $booking->save();
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

    public function reviewDetails($id)
    {
        $booking = Booking::with([
            'bookingDetails.review',
            'bookingDetails.room.hotel.hotelImages',
            'bookingDetails.room.hotel.hotelFacilities.icon'
        ])->find($id);
        if (!$booking) {
            return response()->json([
                'message' => 'Booking tidak ditemukan'
            ], 404);
        }
        $bookingDetail = $booking->bookingDetails->first();
        $room = $bookingDetail?->room;
        $review = $bookingDetail?->review;
        return response()->json([
            'data' => [
                'hotel' => [
                    'name' => $room->hotel->name ?? 'Unknown Hotel',
                    'hotel_images' => $room->hotel->hotelImages ?? [],
                    'hotel_facilities' => $room->hotel->hotelFacilities ?? [],
                ],
                'room_type' => $room->type ?? 'Standard Room',
                'check_out' => $booking->check_out,
                'user_id' => $booking->user_id,
                'room_id' => $room->id,
                'booking_detail_id' => $bookingDetail->id,
                'review' => $review,
            ]
        ], 200);
    }

    private function generateQrCodes(
        string $bookingNumber
    ) {
        $qrBookingNumber = "Kode Booking {$bookingNumber}";

        $qrCode = null;

        try {
            $qrResponse = Http::timeout(10)->get('https://api.qrserver.com/v1/create-qr-code/?size=150x150&margin=2&data=' . urlencode($qrBookingNumber));
            if ($qrResponse->successful()) {
                $qrCode = base64_encode($qrResponse->body());
            }
        } catch (\Exception) {
        }

        return [$qrCode];
    }
}
