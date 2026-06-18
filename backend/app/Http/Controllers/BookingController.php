<?php

namespace App\Http\Controllers;

use App\Models\Booking;
use App\Models\BookingDetail;
use App\Models\Room;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class BookingController extends Controller
{
    public function index()
    {
        $userId = Auth::user()->id;

        $bookings = Booking::with([
            'bookingDetails:id,booking_id,room_id,total_room,sub_total',
            'bookingDetails.room:id,hotel_id,type,price',
            'bookingDetails.room.hotel:id,name,location',
            'bookingDetails.room.hotel.hotelImage',
        ])
            ->where('user_id', $userId)
            ->orderBy('id', 'desc')
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

    public function store(Request $request)
    {

        $validated = $request->validate([
            'check_in' => 'required|date|after_or_equal:today',
            'check_out' => 'required|date|after:check_in',
            'status' => ['required', Rule::in(['paid', 'completed', 'cancelled'])],
        ]);

        $validated['total_price'] = 0;


        $validated['user_id'] = Auth::user()->id;

        if ($validated['status'] != "cancelled") {
            $validated['booking_number'] = 'BK-' . strtoupper(Str::random(8));
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

        $updates = [];

        foreach ($booking->bookingDetails as $detail) {
            $roomPrice = $detail->room->price ?? 0;
            $addOnPrice = 0;

            foreach ($detail->addOns as $detailAddOn) {
                $addOnPrice += ($detailAddOn->addOn->price ?? 0) * $detailAddOn->qty;
            }

            $subTotal = ($roomPrice * $detail->total_room) + $addOnPrice;
            $updates[$detail->id] = $subTotal;
            $totalPrice += $subTotal;
        }

        \DB::transaction(function () use ($updates, $booking, $totalPrice, $duration) {
            foreach ($updates as $id => $subTotal) {
                BookingDetail::where('id', $id)->update(['sub_total' => $subTotal]);
            }
            $booking->total_price = $totalPrice * $duration;
            $booking->save();
        });
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
            'bookingDetails.room.hotel.hotelImage',
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
                    'hotel_image' => $room->hotel->hotelImage ?? '',
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

    public function storeFull(Request $request)
    {
        $validated = $request->validate([
            'check_in'  => 'required|date|after_or_equal:today',
            'check_out' => 'required|date|after:check_in',
            'status'    => ['required', Rule::in(['paid', 'completed', 'cancelled'])],
            'items'                       => 'required|array|min:1',
            'items.*.room_id'             => 'required|exists:rooms,id',
            'items.*.total_room'          => 'required|integer|min:1',
            'items.*.notes'               => 'nullable|string',
            'items.*.add_ons'             => 'array',
            'items.*.add_ons.*.add_on_id' => 'required|exists:add_ons,id',
            'items.*.add_ons.*.qty'       => 'required|integer|min:1',
        ]);

        $booking = DB::transaction(function () use ($validated) {
            $booking = Booking::create([
                'user_id'        => Auth::id(),
                'check_in'       => $validated['check_in'],
                'check_out'      => $validated['check_out'],
                'status'         => $validated['status'],
                'booking_number' => $validated['status'] !== 'cancelled'
                    ? 'BK-' . strtoupper(Str::random(8)) : null,
                'total_price'    => 0,
            ]);

            $roomIds = collect($validated['items'])->pluck('room_id')->unique();
            $rooms   = Room::whereIn('id', $roomIds)->get()->keyBy('id');

            $addOnIds = collect($validated['items'])
                ->flatMap(fn($i) => collect($i['add_ons'] ?? [])->pluck('add_on_id'))
                ->unique();
            $addOns = \App\Models\AddOn::whereIn('id', $addOnIds)->get()->keyBy('id');

            $duration = max(1, (int) Carbon::parse($validated['check_in'])
                ->diffInDays(Carbon::parse($validated['check_out'])));

            $total = 0;
            foreach ($validated['items'] as $item) {
                $room     = $rooms[$item['room_id']];
                $addOnSum = 0;
                $rows     = [];

                foreach ($item['add_ons'] ?? [] as $ao) {
                    $price     = $addOns[$ao['add_on_id']]->price ?? 0;
                    $addOnSum += $price * $ao['qty'];
                    $rows[]    = [
                        'add_on_id' => $ao['add_on_id'],
                        'qty'       => $ao['qty'],
                        'sub_total' => $price * $ao['qty'],
                    ];
                }

                $subTotal = ($room->price * $item['total_room']) + $addOnSum;

                $detail = $booking->bookingDetails()->create([
                    'room_id'    => $item['room_id'],
                    'total_room' => $item['total_room'],
                    'notes'      => $item['notes'] ?? null,
                    'sub_total'  => $subTotal,
                ]);

                foreach ($rows as &$r) $r['booking_detail_id'] = $detail->id;
                if ($rows) \App\Models\BookingDetailAddOn::insert($rows);

                $total += $subTotal;
            }

            $booking->update(['total_price' => $total * $duration]);
            return $booking;
        });

        return response()->json([
            'message' => 'Booking created',
            'booking' => $booking->load('bookingDetails.addOns.addOn'),
        ], 201);
    }
}
