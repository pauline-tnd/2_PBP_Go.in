<?php

namespace App\Http\Controllers;

use App\Models\RoomFacility;
use Illuminate\Http\Request;

class RoomFacilityController extends Controller
{
    public function index()
    {
        $facilities = RoomFacility::with('icon')->get();

        return response()->json([
            'data' => $facilities
        ], 200);
    }
}
