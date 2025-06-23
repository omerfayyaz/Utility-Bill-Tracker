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
        Schema::table('daily_readings', function (Blueprint $table) {
            // Drop the old unique constraint
            $table->dropUnique(['billing_cycle_id', 'reading_date']);

            // Add new unique constraint that includes time
            $table->unique(['billing_cycle_id', 'reading_date', 'reading_time'], 'daily_readings_unique_date_time');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('daily_readings', function (Blueprint $table) {
            // Drop the new unique constraint
            $table->dropUnique('daily_readings_unique_date_time');

            // Restore the old unique constraint
            $table->unique(['billing_cycle_id', 'reading_date']);
        });
    }
};
