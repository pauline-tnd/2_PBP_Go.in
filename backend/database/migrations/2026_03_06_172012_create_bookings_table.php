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
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id') // otomatis menebak users(id)
                ->constrained()
                ->cascadeOnDelete();

            $table->string('booking_number')->unique()->nullable();
            $table->string('qr_code')->nullable();

            $table->date('check_in');
            $table->date('check_out');

            $table->decimal('total_price', 10, 2);

            $table->enum('status', ['paid', 'completed', 'cancelled'])
                ->default('paid');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
