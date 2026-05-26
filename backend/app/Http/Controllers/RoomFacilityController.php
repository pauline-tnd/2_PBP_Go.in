<?php

namespace App\Http\Controllers;

use App\Models\RoomFacility;

class RoomFacilityController extends Controller
{
    public function index()
    {
        $facilities = RoomFacility::with('icon')->get();

        return response()->json([
            'data' => $facilities,
        ], 200);
    }
}
