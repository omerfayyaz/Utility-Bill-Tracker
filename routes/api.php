<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DailyReadingController;
use App\Http\Controllers\BillingCycleController;
use App\Http\Controllers\AuthController;

// Public routes
Route::post('/login', [AuthController::class, 'apiLogin']);
Route::post('/register', [AuthController::class, 'apiRegister']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'apiLogout']);
    Route::get('/user', [AuthController::class, 'apiUser']);

    // Billing Cycles
    Route::get('/billing-cycles', [BillingCycleController::class, 'apiIndex']);
    Route::post('/billing-cycles', [BillingCycleController::class, 'apiStore']);
    Route::get('/billing-cycles/{billingCycle}', [BillingCycleController::class, 'apiShow']);
    Route::put('/billing-cycles/{billingCycle}', [BillingCycleController::class, 'apiUpdate']);
    Route::delete('/billing-cycles/{billingCycle}', [BillingCycleController::class, 'apiDestroy']);

    // Daily Readings
    Route::get('/daily-readings', [DailyReadingController::class, 'apiIndex']);
    Route::post('/daily-readings', [DailyReadingController::class, 'apiStore']);
    Route::get('/daily-readings/{dailyReading}', [DailyReadingController::class, 'apiShow']);
    Route::put('/daily-readings/{dailyReading}', [DailyReadingController::class, 'apiUpdate']);
    Route::delete('/daily-readings/{dailyReading}', [DailyReadingController::class, 'apiDestroy']);
    Route::post('/daily-readings/offline-sync', [DailyReadingController::class, 'offlineSync']);
});

