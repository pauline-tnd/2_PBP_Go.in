<?php

namespace App\Http\Controllers;

use App\Models\AddOn;

class AddOnController extends Controller
{
    public function index() // image detail
    {
        $addOns = AddOn::with(['hotel', 'icon'])->get();

        return response()->json([ // success
            'data' => $addOns,
        ], 200);
    }
}
