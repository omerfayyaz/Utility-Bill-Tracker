<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BillingCycle extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'start_date',
        'start_reading',
        'end_date',
        'end_reading',
        'is_active',
    ];

    protected $casts = [
        'start_date' => 'date',
        'end_date' => 'date',
        'start_reading' => 'decimal:2',
        'end_reading' => 'decimal:2',
        'is_active' => 'boolean',
    ];

    public function dailyReadings(): HasMany
    {
        return $this->hasMany(DailyReading::class);
    }

    public function getTotalConsumedUnitsAttribute(): float
    {
        $latestReading = $this->dailyReadings()
            ->orderBy('reading_date', 'desc')
            ->orderBy('reading_time', 'desc')
            ->first();

        if (!$latestReading) {
            return 0;
        }

        return $latestReading->reading_value - $this->start_reading;
    }

    public function getCurrentReadingAttribute(): float
    {
        $latestReading = $this->dailyReadings()->latest('reading_date')->first();
        return $latestReading ? $latestReading->reading_value : $this->start_reading;
    }

    public function getDaysElapsedAttribute(): int
    {
        return $this->start_date->diffInDays(now());
    }
}
