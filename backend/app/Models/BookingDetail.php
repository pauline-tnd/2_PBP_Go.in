<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BookingDetail extends Model
{
    use HasFactory;

    protected $table = 'booking_details';
    protected $primaryKey = 'id';
    public $incrementing = true;
    protected $keyType = 'bigint';

    protected $fillable = [
        'booking_id',
        'room_id',
        'total_room',
        'sub_total',
        'notes',
    ];

    protected $casts = [
        'total_room' => 'integer',
        'sub_total' => 'decimal:2',
        'notes' => 'string',
    ];

    public function booking()
    {
        return $this->belongsTo(Booking::class, 'booking_id');
    }

    public function room()
    {
        return $this->belongsTo(Room::class, 'room_id');
    }

    public function addOns()
    {
        return $this->hasMany(BookingDetailAddOn::class, 'booking_detail_id');
    }
}