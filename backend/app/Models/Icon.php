<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Icon extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'icon',
        'name'
    ];

    protected $casts = [
        'icon' => 'string',
        'name' => 'string',
    ];

    public function hotelFacilities()
    {
        return $this->hasMany(HotelFacility::class, 'icon_id');
    }

    public function roomFacilities()
    {
        return $this->hasMany(RoomFacility::class, 'icon_id');
    }

    public function addOns()
    {
        return $this->hasMany(AddOn::class, 'icon_id');
    }
}
