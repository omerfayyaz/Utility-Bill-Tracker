<?php

namespace App\Http\Controllers;

use App\Models\BillingCycle;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;

class BillingCycleController extends Controller
{
    public function index(): View
    {
        $billingCycles = Auth::user()->billingCycles()
            ->with('dailyReadings')
            ->orderBy('created_at', 'desc')
            ->get();

        return view('billing-cycles.index', compact('billingCycles'));
    }

    public function create(): View
    {
        return view('billing-cycles.create');
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date|before_or_equal:today',
            'start_reading' => 'required|numeric|min:0',
        ]);

        // Deactivate other active cycles for this user
        Auth::user()->billingCycles()
            ->where('is_active', true)
            ->update(['is_active' => false]);

        Auth::user()->billingCycles()->create($validated);

        return redirect()->route('billing-cycles.index')
            ->with('success', 'Billing cycle created successfully!');
    }

    public function show(BillingCycle $billingCycle): View
    {
        // Ensure user can only access their own billing cycles
        if ($billingCycle->user_id !== Auth::id()) {
            abort(403);
        }

        $billingCycle->load(['dailyReadings' => function ($query) {
            $query->orderBy('reading_date', 'desc');
        }]);

        return view('billing-cycles.show', compact('billingCycle'));
    }

    public function edit(BillingCycle $billingCycle): View
    {
        // Ensure user can only access their own billing cycles
        if ($billingCycle->user_id !== Auth::id()) {
            abort(403);
        }

        return view('billing-cycles.edit', compact('billingCycle'));
    }

    public function update(Request $request, BillingCycle $billingCycle): RedirectResponse
    {
        // Ensure user can only access their own billing cycles
        if ($billingCycle->user_id !== Auth::id()) {
            abort(403);
        }

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date|before_or_equal:today',
            'start_reading' => 'required|numeric|min:0',
            'end_date' => 'nullable|date|after:start_date',
            'end_reading' => 'nullable|numeric|min:0',
        ]);

        $billingCycle->update($validated);

        return redirect()->route('billing-cycles.show', $billingCycle)
            ->with('success', 'Billing cycle updated successfully!');
    }

    public function destroy(BillingCycle $billingCycle): RedirectResponse
    {
        // Ensure user can only access their own billing cycles
        if ($billingCycle->user_id !== Auth::id()) {
            abort(403);
        }

        $cycleId = $billingCycle->id;
        $cycleName = $billingCycle->name;

        \Log::info("Deleting billing cycle", [
            'cycle_id' => $cycleId,
            'cycle_name' => $cycleName,
            'model_class' => get_class($billingCycle)
        ]);

        $billingCycle->delete();

        return redirect()->route('billing-cycles.index')
            ->with('success', "Billing cycle '{$cycleName}' deleted successfully!");
    }
}
