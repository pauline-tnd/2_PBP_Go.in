<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RoomFacility extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'room_id',
        'icon_id',
        'name',
    ];

    protected $casts = [
        'name' => 'string',
    ];

    public function room()
    {
        return $this->belongsTo(Room::class, 'room_id');
    }

    public function icon()
    {
        return $this->belongsTo(Icon::class, 'icon_id');
    }
}
