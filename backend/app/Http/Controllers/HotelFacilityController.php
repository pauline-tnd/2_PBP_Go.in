<?php

namespace App\Http\Controllers;

use App\Models\HotelFacility;

class HotelFacilityController extends Controller
{
    public function index()
    {
        $facilities = HotelFacility::with('icon')->get();

        return response()->json([
            'data' => $facilities,
        ], 200);
    }
}
