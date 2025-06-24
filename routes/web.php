<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BillingCycleController;
use App\Http\Controllers\DailyReadingController;
use App\Http\Controllers\AuthController;

// Authentication routes
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);
});

Route::middleware('auth')->group(function () {
    Route::get('/', function () {
        return redirect()->route('daily-readings.index');
    });

    Route::resource('billing-cycles', BillingCycleController::class);
    Route::resource('daily-readings', DailyReadingController::class);

    // Quick add route for today's reading
    Route::get('/quick-add', [DailyReadingController::class, 'quickAdd'])->name('daily-readings.quick-add');
    Route::post('/quick-add', [DailyReadingController::class, 'quickStore'])->name('daily-readings.quick-store');

    // Logout route
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
});

// PWA Offline page (public)
Route::get('/offline', function () {
    return view('offline');
})->name('offline');
