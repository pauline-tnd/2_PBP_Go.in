<?php

namespace App\Http\Controllers;

use App\Models\Room;
use Illuminate\Http\Request;

class RoomController extends Controller
{
    public function index($hotelId) // all rooms in hotel
    {
        $rooms = Room::where('hotel_id', $hotelId)->with([
            'roomImage',
            'roomFacilities.icon', // king bed, size ?
        ])->get();

        return response()->json([
            'data' => $rooms,
        ], 200);
    }

    public function show($hotelId, string $id) // hotel detail
    {
        $room = Room::where('hotel_id', $hotelId)->with([
            'roomImages',
            'roomFacilities.icon', // facilities and icon
            'hotel.addOns.icon' // get add on from hotel
        ])->find($id);

        if (!$room) { // invalid id
            return response()->json([
                'message' => 'Room not found',
            ], 404);
        }

        return response()->json([ // success
            'data' => $room
        ], 200);
    }
}
