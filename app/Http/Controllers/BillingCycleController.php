<?php

namespace App\Http\Controllers;

use App\Models\BillingCycle;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;

class BillingCycleController extends Controller
{
    public function index(): View
    {
        $billingCycles = BillingCycle::with('dailyReadings')
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
            'start_date' => 'required|date',
            'start_reading' => 'required|numeric|min:0',
        ]);

        // Deactivate other active cycles
        BillingCycle::where('is_active', true)->update(['is_active' => false]);

        BillingCycle::create($validated);

        return redirect()->route('billing-cycles.index')
            ->with('success', 'Billing cycle created successfully!');
    }

    public function show(BillingCycle $billingCycle): View
    {
        $billingCycle->load(['dailyReadings' => function ($query) {
            $query->orderBy('reading_date', 'desc');
        }]);

        return view('billing-cycles.show', compact('billingCycle'));
    }

    public function edit(BillingCycle $billingCycle): View
    {
        return view('billing-cycles.edit', compact('billingCycle'));
    }

    public function update(Request $request, BillingCycle $billingCycle): RedirectResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date',
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
        $billingCycle->delete();

        return redirect()->route('billing-cycles.index')
            ->with('success', 'Billing cycle deleted successfully!');
    }
}
