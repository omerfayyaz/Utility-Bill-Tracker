<?php

namespace App\Http\Controllers;

use App\Models\BillingCycle;
use App\Models\DailyReading;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Database\QueryException;
use Carbon\Carbon;

class DailyReadingController extends Controller
{
    public function index(): View
    {
        $activeCycle = BillingCycle::where('is_active', true)->first();
        $readings = collect();

        if ($activeCycle) {
            $readings = $activeCycle->dailyReadings()
                ->orderBy('reading_date', 'asc')
                ->orderBy('reading_time', 'asc')
                ->get();
        }

        return view('daily-readings.index', compact('activeCycle', 'readings'));
    }

    public function create(): View
    {
        $activeCycle = BillingCycle::where('is_active', true)->first();

        if (!$activeCycle) {
            return redirect()->route('billing-cycles.create')
                ->with('error', 'Please create a billing cycle first!');
        }

        return view('daily-readings.create', compact('activeCycle'));
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'billing_cycle_id' => 'required|exists:billing_cycles,id',
            'reading_date' => 'required|date',
            'reading_time' => 'required|date_format:H:i',
            'reading_value' => 'required|numeric|min:0',
            'notes' => 'nullable|string',
        ]);

        // Check if reading already exists for this date and time
        $existingReading = DailyReading::where('billing_cycle_id', $validated['billing_cycle_id'])
            ->where('reading_date', $validated['reading_date'])
            ->where('reading_time', $validated['reading_time'])
            ->first();

        if ($existingReading) {
            return back()->withErrors([
                'reading_time' => "A reading already exists for {$validated['reading_date']} at {$validated['reading_time']}. Please choose a different time."
            ])->withInput();
        }

        // Validate reading value is logically consistent
        $validationError = $this->validateReadingValue($validated['billing_cycle_id'], $validated['reading_date'], $validated['reading_time'], $validated['reading_value']);
        if ($validationError) {
            return back()->withErrors(['reading_value' => $validationError])->withInput();
        }

        try {
            DailyReading::create($validated);
            return redirect()->route('daily-readings.index')
                ->with('success', 'Daily reading added successfully!');
        } catch (QueryException $e) {
            if (str_contains($e->getMessage(), 'UNIQUE constraint failed')) {
                return back()->withErrors([
                    'reading_time' => "A reading already exists for {$validated['reading_date']} at {$validated['reading_time']}. Please choose a different time."
                ])->withInput();
            }
            throw $e;
        }
    }

    public function show(DailyReading $dailyReading): View
    {
        return view('daily-readings.show', compact('dailyReading'));
    }

    public function edit(DailyReading $dailyReading): View
    {
        return view('daily-readings.edit', compact('dailyReading'));
    }

    public function update(Request $request, DailyReading $dailyReading): RedirectResponse
    {
        $validated = $request->validate([
            'reading_date' => 'required|date',
            'reading_time' => 'required|date_format:H:i',
            'reading_value' => 'required|numeric|min:0',
            'notes' => 'nullable|string',
        ]);

        // Check if reading already exists for this date and time (excluding current reading)
        $existingReading = DailyReading::where('billing_cycle_id', $dailyReading->billing_cycle_id)
            ->where('reading_date', $validated['reading_date'])
            ->where('reading_time', $validated['reading_time'])
            ->where('id', '!=', $dailyReading->id)
            ->first();

        if ($existingReading) {
            return back()->withErrors([
                'reading_time' => "A reading already exists for {$validated['reading_date']} at {$validated['reading_time']}. Please choose a different time."
            ])->withInput();
        }

        // Validate reading value is logically consistent (excluding current reading)
        $validationError = $this->validateReadingValue($dailyReading->billing_cycle_id, $validated['reading_date'], $validated['reading_time'], $validated['reading_value'], $dailyReading->id);
        if ($validationError) {
            return back()->withErrors(['reading_value' => $validationError])->withInput();
        }

        try {
            $dailyReading->update($validated);
            return redirect()->route('daily-readings.index')
                ->with('success', 'Daily reading updated successfully!');
        } catch (QueryException $e) {
            if (str_contains($e->getMessage(), 'UNIQUE constraint failed')) {
                return back()->withErrors([
                    'reading_time' => "A reading already exists for {$validated['reading_date']} at {$validated['reading_time']}. Please choose a different time."
                ])->withInput();
            }
            throw $e;
        }
    }

    public function destroy(DailyReading $dailyReading): RedirectResponse
    {
        $dailyReading->delete();

        return redirect()->route('daily-readings.index')
            ->with('success', 'Daily reading deleted successfully!');
    }

    public function quickAdd(): View
    {
        $activeCycle = BillingCycle::where('is_active', true)->first();

        if (!$activeCycle) {
            return redirect()->route('billing-cycles.create')
                ->with('error', 'Please create a billing cycle first!');
        }

        return view('daily-readings.quick-add', compact('activeCycle'));
    }

    public function quickStore(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'billing_cycle_id' => 'required|exists:billing_cycles,id',
            'reading_value' => 'required|numeric|min:0',
            'reading_time' => 'required|date_format:H:i',
            'notes' => 'nullable|string',
        ]);

        $validated['reading_date'] = now()->toDateString();

        // Check if reading already exists for today at this time
        $existingReading = DailyReading::where('billing_cycle_id', $validated['billing_cycle_id'])
            ->where('reading_date', $validated['reading_date'])
            ->where('reading_time', $validated['reading_time'])
            ->first();

        if ($existingReading) {
            return back()->withErrors([
                'reading_time' => "A reading already exists for today at {$validated['reading_time']}. Please choose a different time."
            ])->withInput();
        }

        // Validate reading value is logically consistent
        $validationError = $this->validateReadingValue($validated['billing_cycle_id'], $validated['reading_date'], $validated['reading_time'], $validated['reading_value']);
        if ($validationError) {
            return back()->withErrors(['reading_value' => $validationError])->withInput();
        }

        try {
            DailyReading::create($validated);
            return redirect()->route('daily-readings.index')
                ->with('success', 'Today\'s reading added successfully!');
        } catch (QueryException $e) {
            if (str_contains($e->getMessage(), 'UNIQUE constraint failed')) {
                return back()->withErrors([
                    'reading_time' => "A reading already exists for today at {$validated['reading_time']}. Please choose a different time."
                ])->withInput();
            }
            throw $e;
        }
    }

    /**
     * Validate that the reading value is logically consistent with chronological order
     */
    private function validateReadingValue(int $billingCycleId, string $readingDate, string $readingTime, float $readingValue, ?int $excludeReadingId = null): ?string
    {
        $readingDateTime = Carbon::parse("{$readingDate} {$readingTime}");

        // Get the billing cycle
        $billingCycle = BillingCycle::find($billingCycleId);
        if (!$billingCycle) {
            return 'Invalid billing cycle.';
        }

        // Get all readings for this cycle, ordered chronologically
        $query = DailyReading::where('billing_cycle_id', $billingCycleId);
        if ($excludeReadingId) {
            $query->where('id', '!=', $excludeReadingId);
        }

        $allReadings = $query->orderBy('reading_date')
            ->orderBy('reading_time')
            ->get();

        // Find the previous reading (chronologically before this one)
        $previousReading = null;
        foreach ($allReadings as $reading) {
            // reading_time is cast as datetime, so we need to format it properly
            $currentDateTime = Carbon::parse($reading->reading_date->format('Y-m-d') . ' ' . $reading->reading_time->format('H:i'));
            if ($currentDateTime->lt($readingDateTime)) {
                $previousReading = $reading;
            } else {
                break;
            }
        }

        // Find the next reading (chronologically after this one)
        $nextReading = null;
        foreach ($allReadings as $reading) {
            // reading_time is cast as datetime, so we need to format it properly
            $currentDateTime = Carbon::parse($reading->reading_date->format('Y-m-d') . ' ' . $reading->reading_time->format('H:i'));
            if ($currentDateTime->gt($readingDateTime)) {
                $nextReading = $reading;
                break;
            }
        }

        // Validate against previous reading
        if ($previousReading && $readingValue < $previousReading->reading_value) {
            $previousDateTime = Carbon::parse($previousReading->reading_date->format('Y-m-d') . ' ' . $previousReading->reading_time->format('H:i'));
            return "Reading value ({$readingValue}) must be greater than or equal to the previous reading ({$previousReading->reading_value}) from {$previousDateTime->format('M d, Y H:i')}.";
        }

        // Validate against next reading
        if ($nextReading && $readingValue >= $nextReading->reading_value) {
            $nextDateTime = Carbon::parse($nextReading->reading_date->format('Y-m-d') . ' ' . $nextReading->reading_time->format('H:i'));
            return "Reading value ({$readingValue}) must be less than the next reading ({$nextReading->reading_value}) from {$nextDateTime->format('M d, Y H:i')}.";
        }

        // Validate against cycle start reading if this is the first reading
        if (!$previousReading && $readingValue < $billingCycle->start_reading) {
            return "Reading value ({$readingValue}) must be greater than or equal to the cycle start reading ({$billingCycle->start_reading}).";
        }

        return null; // No validation error
    }
}
