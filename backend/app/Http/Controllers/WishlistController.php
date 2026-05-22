<?php

namespace App\Http\Controllers;

use App\Models\Wishlist;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class WishlistController extends Controller
{
    public function index()
    {
        $wishlist = Wishlist::with([
            'hotel' => fn($q) => $q->hotelCard()
        ])->get();

        return response()->json([
            'message' => 'Wishlist successfully loaded',
            'data' => $wishlist
        ], 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'hotel_id' => 'required|exists:hotels,id',
        ]);
        
        $validated['user_id'] = Auth::user()->id;

        $wishlist = Wishlist::firstOrCreate($validated);

        return response()->json([
            'message' => $wishlist->wasRecentlyCreated ? 'Wishlist created' : 'Wishlist already exists',
            'data' => $wishlist
        ], $wishlist->wasRecentlyCreated ? 201 : 200);
    }

    public function destroy(Wishlist $wishlist)
    {
        $user = Auth::user()->id;

        if ($user != $wishlist->user_id) {
            return response()->json([
                'message' => 'Unauthenticated'
            ], 401);
        }

        $wishlist->delete();
        return response()->json([
            'message' => 'Wishlist deleted'
        ], 200);
    }
}
