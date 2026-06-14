<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Room extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'hotel_id',
        'type',
        'description',
        'price',
        'capacity',
        'bed_type',
        'room_size'
    ];

    protected $casts = [
        'type' => 'string',
        'description' => 'string',
        'price' => 'decimal:2',
        'capacity' => 'integer',
        'bed_type' => 'string',
        'room_size' => 'integer',
    ];

    public function roomImage()
    {
        return $this->hasOne(RoomImage::class, 'room_id');
    }

    public function roomImages()
    {
        return $this->hasMany(RoomImage::class, 'room_id');
    }

    public function roomFacilities()
    {
        return $this->hasMany(RoomFacility::class, 'room_id');
    }

    public function addOns()
    {
        return $this->hasMany(AddOn::class, 'room_id');
    }

    public function bookingDetails()
    {
        return $this->hasMany(BookingDetail::class, 'room_id');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class, 'room_id');
    }

    public function hotel()
    {
        return $this->belongsTo(Hotel::class, 'hotel_id');
    }
}
