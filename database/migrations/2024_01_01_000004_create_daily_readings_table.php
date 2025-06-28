<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('daily_readings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('billing_cycle_id')->constrained()->onDelete('cascade');
            $table->date('reading_date');
            $table->time('reading_time');
            $table->decimal('reading_value', 10, 2);
            $table->decimal('consumed_units', 10, 2)->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            // No unique constraints needed
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('daily_readings');
    }
};
