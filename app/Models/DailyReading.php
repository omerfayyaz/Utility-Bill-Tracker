<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DailyReading extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'billing_cycle_id',
        'reading_date',
        'reading_time',
        'reading_value',
        'notes',
    ];

    protected $casts = [
        'reading_date' => 'date',
        'reading_time' => 'datetime:H:i',
        'reading_value' => 'decimal:2',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function billingCycle(): BelongsTo
    {
        return $this->belongsTo(BillingCycle::class);
    }
}
