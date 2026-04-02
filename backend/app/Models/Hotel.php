<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Hotel extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'star',
        'location',
        'latitude',
        'longitude',
    ];

    public function rooms()
    {
        return $this->hasMany(Room::class, 'hotel_id');
    }

    public function hotelImage() // display image
    {
        return $this->hasOne(HotelImage::class, 'hotel_id');
    }

    public function hotelImages() // detail hotel image
    {
        return $this->hasMany(HotelImage::class, 'hotel_id');
    }

    public function hotelFacilities()
    {
        return $this->hasMany(HotelFacility::class, 'hotel_id');
    }

    public function addOns()
    {
        return $this->hasMany(AddOn::class, 'hotel_id');
    }

    public function wishlists()
    {
        return $this->hasMany(Wishlist::class, 'hotel_id');
    }

    public function reviews() // Hotel has many Review, through Room
    {
        return $this->hasManyThrough(Review::class, Room::class);
    }

    public function bookingDetails() // Hotel has many Bookings, through Room
    {
        return $this->hasManyThrough(BookingDetail::class, Room::class);
    }
}
