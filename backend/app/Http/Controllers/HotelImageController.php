<?php

namespace App\Http\Controllers;

use App\Models\HotelImage;

class HotelImageController extends Controller
{
    public function show(string $id) // image detail
    {
        $hotelImage = HotelImage::with('hotel')
            ->find($id);

        if (! $hotelImage) { // invalid id
            return response()->json([
                'message' => 'Image not found',
            ], 404);
        }

        return response()->json([ // success
            'data' => $hotelImage,
        ], 200);
    }
}
