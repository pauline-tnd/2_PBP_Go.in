<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BookingDetailAddOn extends Model
{
    use HasFactory;

    protected $table = 'booking_detail_add_ons';

    protected $primaryKey = 'id';

    public $incrementing = true;

    protected $keyType = 'int';

    protected $fillable = [
        'booking_detail_id',
        'add_on_id',
        'qty',
        'sub_total',
    ];

    protected $casts = [
        'qty' => 'integer',
        'sub_total' => 'decimal:2',
    ];

    public function bookingDetail()
    {
        return $this->belongsTo(BookingDetail::class, 'booking_detail_id');
    }

    public function addOn()
    {
        return $this->belongsTo(AddOn::class, 'add_on_id');
    }
}
