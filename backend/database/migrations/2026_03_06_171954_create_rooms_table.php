<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('rooms', function (Blueprint $table) {
            $table->id();
            $table->foreignId('hotel_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->string('type');
            $table->text('description')->nullable();

            $table->tinyInteger('capacity')->unsigned();
            $table->decimal('price', 10, 2);
            $table->tinyInteger('room_size')->unsigned()->nullable();
            $table->string('bed_type')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rooms');
    }
};
