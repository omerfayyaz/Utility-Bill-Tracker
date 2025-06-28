<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BillingCycleResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'name' => $this->name,
            'start_date' => optional($this->start_date)->toDateString(),
            'start_reading' => $this->start_reading,
            'end_date' => optional($this->end_date)->toDateString(),
            'end_reading' => $this->end_reading,
            'is_active' => $this->is_active,
            'created_at' => $this->created_at->toIso8601String(),
            'updated_at' => $this->updated_at->toIso8601String(),
            'daily_readings' => DailyReadingResource::collection($this->whenLoaded('dailyReadings')),
        ];
    }
}
