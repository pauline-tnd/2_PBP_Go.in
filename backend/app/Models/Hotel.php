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

    protected $casts = [
        'name' => 'string',
        'description' => 'string',
        'star' => 'integer',
        'location' => 'string',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
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

    // Hotel.php
    public function scopeHotelCard($query)
    {
        return $query->with('hotelImage')
            ->withMin('rooms as start_from_price', 'price')
            ->withAvg('reviews as hotel_rating', 'rating')
            ->withCount('bookingDetails as total_bookings');
    }
}
