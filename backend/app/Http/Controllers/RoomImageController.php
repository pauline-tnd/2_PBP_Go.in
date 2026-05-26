<?php

namespace App\Http\Controllers;

use App\Models\RoomImage;

class RoomImageController extends Controller
{
    public function show(string $id) // image detail
    {
        $roomImage = RoomImage::with('room')
            ->find($id);

        if (! $roomImage) { // invalid id
            return response()->json([
                'message' => 'Image not found',
            ], 404);
        }

        return response()->json([ // success
            'data' => $roomImage,
        ], 200);
    }
}
