<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use App\Models\User;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Create a default user if no users exist
        $defaultUser = User::first();
        if (!$defaultUser) {
            $defaultUser = User::create([
                'name' => 'Default User',
                'email' => 'default@example.com',
                'password' => bcrypt('password'),
            ]);
        }

        // Add user_id column to billing_cycles table
        Schema::table('billing_cycles', function (Blueprint $table) {
            $table->foreignId('user_id')->after('id')->nullable();
        });

        // Update existing billing cycles to belong to the default user
        \DB::table('billing_cycles')->update(['user_id' => $defaultUser->id]);

        // Make user_id not nullable and add foreign key constraint
        Schema::table('billing_cycles', function (Blueprint $table) {
            $table->foreignId('user_id')->nullable(false)->change();
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });

        // Add user_id column to daily_readings table
        Schema::table('daily_readings', function (Blueprint $table) {
            $table->foreignId('user_id')->after('id')->nullable();
        });

        // Update existing daily readings to belong to the default user
        \DB::table('daily_readings')->update(['user_id' => $defaultUser->id]);

        // Make user_id not nullable and add foreign key constraint
        Schema::table('daily_readings', function (Blueprint $table) {
            $table->foreignId('user_id')->nullable(false)->change();
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('daily_readings', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropColumn('user_id');
        });

        Schema::table('billing_cycles', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropColumn('user_id');
        });
    }
};
