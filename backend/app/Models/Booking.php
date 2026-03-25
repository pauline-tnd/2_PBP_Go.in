<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    protected $primaryKey = 'book_id';
    public $incrementing = true;
    protected $keyType = 'bigint';

    protected $fillable = [
        'user_id',
        'room_id',
        'booking_number',
        'qr_code',
        'check_in',
        'check_out',
        'total_price',
        'status',
    ];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
        'total_price' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function room()
    {
        return $this->belongsTo(Room::class, 'room_id');
    }

    public function hotel()
    {
        return $this->hasOneThrough(
            Hotel::class,
            Room::class,
            'id',
            'id',
            'room_id',
            'hotel_id'
        );
    }
}