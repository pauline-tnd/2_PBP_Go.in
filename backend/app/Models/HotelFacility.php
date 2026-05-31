<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class HotelFacility extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'hotel_id',
        'icon_id',
        'name',
    ];

    protected $casts = [
        'name' => 'string',
    ];

    public function hotel()
    {
        return $this->belongsTo(Hotel::class, 'hotel_id');
    }

    public function icon()
    {
        return $this->belongsTo(Icon::class);
    }
}
