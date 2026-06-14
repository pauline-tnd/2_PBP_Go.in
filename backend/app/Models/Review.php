<?php

namespace App\Models;

// use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    // use HasFactory;

    protected $table = 'reviews';
    protected $primaryKey = 'id';
    public $incrementing = true;
    protected $keyType = 'int';

    protected $fillable = [
        'user_id',
        'room_id',
        'booking_detail_id',
        'rating',
        'description',
        'image',
    ];

    protected $casts = [
    'rating' => 'integer',
    'description' => 'string',
    'image' => 'string',
    'created_at' => 'datetime:Y-m-d H:i:s',
    'updated_at' => 'datetime:Y-m-d H:i:s',
];

    protected $appends = ['image_url'];

    public function getImageUrlAttribute()
    {
        return $this->image
            ? asset('storage/' . $this->image)
            : null;
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function room()
    {
        return $this->belongsTo(Room::class, 'room_id');
    }

    public function bookingDetail()
    {
        return $this->belongsTo(BookingDetail::class, 'booking_detail_id');
    }
}
