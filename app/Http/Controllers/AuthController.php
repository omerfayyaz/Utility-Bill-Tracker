<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Illuminate\Validation\ValidationException;
use App\Http\Resources\UserResource;

class AuthController extends Controller
{
    public function showLogin()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if (Auth::attempt($credentials, $request->boolean('remember'))) {
            $request->session()->regenerate();
            return redirect()->intended(route('daily-readings.index'));
        }

        return back()->withErrors([
            'email' => 'The provided credentials do not match our records.',
        ])->onlyInput('email');
    }

    public function showRegister()
    {
        return view('auth.register');
    }

    public function register(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
        ]);

        Auth::login($user);

        return redirect()->route('daily-readings.index');
    }

    public function logout(Request $request)
    {
        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }

    // API: Login
    public function apiLogin(Request $request)
    {
        \Log::info('API /api/login called', [
            'email' => $request->email,
            'ip' => $request->ip(),
        ]);
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);
        $user = User::where('email', $request->email)->first();
        if (! $user || ! Hash::check($request->password, $user->password)) {
            \Log::warning('API /api/login failed', [
                'email' => $request->email,
                'ip' => $request->ip(),
            ]);
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }
        $token = $user->createToken('mobile')->plainTextToken;
        \Log::info('API /api/login success', [
            'user_id' => $user->id,
            'ip' => $request->ip(),
        ]);
        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ]);
    }

    // API: Register
    public function apiRegister(Request $request)
    {
        \Log::info('API /api/register called', [
            'email' => $request->email,
            'ip' => $request->ip(),
        ]);
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);
        $token = $user->createToken('mobile')->plainTextToken;
        \Log::info('API /api/register success', [
            'user_id' => $user->id,
            'ip' => $request->ip(),
        ]);
        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ], 201);
    }

    // API: Logout
    public function apiLogout(Request $request)
    {
        \Log::info('API /api/logout called', [
            'user_id' => $request->user()->id,
            'ip' => $request->ip(),
        ]);
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out successfully']);
    }

    // API: Get Authenticated User
    public function apiUser(Request $request)
    {
        \Log::info('API /api/user called', [
            'user_id' => $request->user()->id,
            'ip' => $request->ip(),
        ]);
        return new UserResource($request->user());
    }
}
