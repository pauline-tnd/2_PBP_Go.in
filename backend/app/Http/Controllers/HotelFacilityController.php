<?php

namespace App\Http\Controllers;

use App\Models\HotelFacility;
use Illuminate\Http\Request;

class HotelFacilityController extends Controller
{
    public function index()
    {
        $facilities = HotelFacility::with('icon')->get();

        return response()->json([
            'data' => $facilities
        ], 200);
    }
}
