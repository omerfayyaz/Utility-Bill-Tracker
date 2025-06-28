<?php

namespace App\Http\Controllers;

use App\Models\BillingCycle;
use Illuminate\Http\Request;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\Auth;
use App\Http\Resources\BillingCycleResource;

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
            $query->orderBy('reading_date', 'asc')
                  ->orderBy('reading_time', 'asc');
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

    // API: List billing cycles
    public function apiIndex(Request $request)
    {
        \Log::info('API /api/billing-cycles [GET] called', [
            'user_id' => $request->user()->id,
            'ip' => $request->ip(),
        ]);
        $billingCycles = $request->user()->billingCycles()->with('dailyReadings')->orderBy('created_at', 'desc')->get();
        return BillingCycleResource::collection($billingCycles);
    }

    // API: Create billing cycle
    public function apiStore(Request $request)
    {
        \Log::info('API /api/billing-cycles [POST] called', [
            'user_id' => $request->user()->id,
            'ip' => $request->ip(),
            'data' => $request->all(),
        ]);
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date|before_or_equal:today',
            'start_reading' => 'required|numeric|min:0',
        ]);
        $user = $request->user();
        $user->billingCycles()->where('is_active', true)->update(['is_active' => false]);
        $cycle = $user->billingCycles()->create($validated);
        \Log::info('API /api/billing-cycles [POST] success', [
            'user_id' => $user->id,
            'cycle_id' => $cycle->id,
        ]);
        $cycle->load('dailyReadings');
        return new BillingCycleResource($cycle);
    }

    // API: Show billing cycle
    public function apiShow(Request $request, BillingCycle $billingCycle)
    {
        \Log::info('API /api/billing-cycles/{id} [GET] called', [
            'user_id' => $request->user()->id,
            'cycle_id' => $billingCycle->id,
            'ip' => $request->ip(),
        ]);
        if ($billingCycle->user_id !== $request->user()->id) {
            \Log::warning('API /api/billing-cycles/{id} [GET] forbidden', [
                'user_id' => $request->user()->id,
                'cycle_id' => $billingCycle->id,
            ]);
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $billingCycle->load(['dailyReadings' => function ($query) {
            $query->orderBy('reading_date', 'asc')->orderBy('reading_time', 'asc');
        }]);
        return new BillingCycleResource($billingCycle);
    }

    // API: Update billing cycle
    public function apiUpdate(Request $request, BillingCycle $billingCycle)
    {
        \Log::info('API /api/billing-cycles/{id} [PUT] called', [
            'user_id' => $request->user()->id,
            'cycle_id' => $billingCycle->id,
            'ip' => $request->ip(),
            'data' => $request->all(),
        ]);
        if ($billingCycle->user_id !== $request->user()->id) {
            \Log::warning('API /api/billing-cycles/{id} [PUT] forbidden', [
                'user_id' => $request->user()->id,
                'cycle_id' => $billingCycle->id,
            ]);
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'start_date' => 'required|date|before_or_equal:today',
            'start_reading' => 'required|numeric|min:0',
            'end_date' => 'nullable|date|after:start_date',
            'end_reading' => 'nullable|numeric|min:0',
        ]);
        $billingCycle->update($validated);
        \Log::info('API /api/billing-cycles/{id} [PUT] success', [
            'user_id' => $request->user()->id,
            'cycle_id' => $billingCycle->id,
        ]);
        $billingCycle->load('dailyReadings');
        return new BillingCycleResource($billingCycle);
    }

    // API: Delete billing cycle
    public function apiDestroy(Request $request, BillingCycle $billingCycle)
    {
        \Log::info('API /api/billing-cycles/{id} [DELETE] called', [
            'user_id' => $request->user()->id,
            'cycle_id' => $billingCycle->id,
            'ip' => $request->ip(),
        ]);
        if ($billingCycle->user_id !== $request->user()->id) {
            \Log::warning('API /api/billing-cycles/{id} [DELETE] forbidden', [
                'user_id' => $request->user()->id,
                'cycle_id' => $billingCycle->id,
            ]);
            return response()->json(['message' => 'Forbidden'], 403);
        }
        $billingCycle->delete();
        \Log::info('API /api/billing-cycles/{id} [DELETE] success', [
            'user_id' => $request->user()->id,
            'cycle_id' => $billingCycle->id,
        ]);
        return response()->json(['message' => 'Billing cycle deleted successfully']);
    }
}
