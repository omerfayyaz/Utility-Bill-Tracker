<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BillingCycleController;
use App\Http\Controllers\DailyReadingController;

Route::get('/', function () {
    return redirect()->route('daily-readings.index');
});

Route::resource('billing-cycles', BillingCycleController::class);
Route::resource('daily-readings', DailyReadingController::class);

// Quick add route for today's reading
Route::get('/quick-add', [DailyReadingController::class, 'quickAdd'])->name('daily-readings.quick-add');
Route::post('/quick-add', [DailyReadingController::class, 'quickStore'])->name('daily-readings.quick-store');
