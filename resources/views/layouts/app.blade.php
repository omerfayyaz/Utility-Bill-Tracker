<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Utility Bill Logger') }}</title>

    <!-- PWA Meta Tags -->
    <meta name="theme-color" content="#3b82f6">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="default">
    <meta name="apple-mobile-web-app-title" content="Utility Logger">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="description" content="Track your utility consumption daily with offline support">

    <!-- PWA Manifest -->
    <link rel="manifest" href="/manifest.json">

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700" rel="stylesheet" />

    <!-- Scripts -->
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="font-sans antialiased bg-gray-50">
    <!-- Splash Screen Overlay (PWA Standalone Only) -->
    <div id="splash-screen" style="position:fixed;z-index:9999;inset:0;display:none;align-items:center;justify-content:center;background:#14532d;color:white;transition:opacity 0.7s;">
        <div class="text-center">
            <span class="block text-3xl font-bold tracking-wide mb-2">Utility Bill Tracker</span>
            <span class="block text-lg font-light">Loading...</span>
        </div>
    </div>
    <script>
        function isStandalone() {
            return window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true;
        }
        window.addEventListener('DOMContentLoaded', function() {
            if (isStandalone() && !localStorage.getItem('pwaSplashShown')) {
                const splash = document.getElementById('splash-screen');
                if (splash) {
                    splash.style.display = 'flex';
                    setTimeout(function() {
                        splash.style.opacity = 0;
                        setTimeout(() => splash.style.display = 'none', 700);
                    }, 1200);
                    localStorage.setItem('pwaSplashShown', '1');
                }
            }
        });
    </script>
    <div class="min-h-screen">
        <!-- Header -->
        <header class="sticky top-0 z-50 bg-white shadow-sm border-b border-gray-200">
            <div class="max-w-7xl mx-auto px-4">
                <div class="flex justify-between items-center py-4">
                    <div class="flex items-center space-x-4">
                        <!-- Home Icon (shown on main index pages) -->
                        @if(request()->routeIs('daily-readings.index') || request()->routeIs('billing-cycles.index'))
                            <a href="{{ route('daily-readings.index') }}" class="flex items-center text-gray-600 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium transition-colors duration-150">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path>
                                </svg>
                            </a>
                        @else
                            <!-- Back Button (shown on pages other than main index pages) -->
                            <button onclick="history.back()" class="flex items-center text-gray-600 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium transition-colors duration-150">
                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
                                </svg>
                            </button>
                        @endif

                        <h1 class="text-xl font-semibold text-gray-900">
                            <a href="{{ route('daily-readings.index') }}" class="hover:text-blue-600 transition-colors duration-150">
                                <span class="text-lg font-semibold tracking-wide">UTILITY BILL TRACKER</span>
                            </a>
                        </h1>
                    </div>

                    <div class="flex items-center space-x-4">
                        <!-- User Menu -->
                        <div class="relative">
                            <div class="flex items-center space-x-2">
                                {{-- <span class="text-sm text-gray-700">{{ Auth::user()->name }}</span> --}}
                                @if(Auth::user()->email !== 'omerfayyaz.engr@gmail.com')
                                    <form method="POST" action="{{ route('logout') }}" class="inline">
                                        @csrf
                                        <button type="submit" class="text-gray-600 hover:text-red-600 px-2 py-1 rounded text-sm font-medium transition-colors duration-150">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
                                            </svg>
                                        </button>
                                    </form>
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <!-- Page Content -->
        <main class="max-w-7xl mx-auto px-4 py-6">
            @if (session('success'))
                <div class="mb-6 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg">
                    {{ session('success') }}
                </div>
            @endif

            @if (session('error'))
                <div class="mb-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                    {{ session('error') }}
                </div>
            @endif

            @if ($errors->any())
                <div class="mb-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                    <ul class="list-disc list-inside">
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            {{ $slot }}
        </main>

        <!-- Mobile Bottom Navigation (Always Visible) -->
        <div class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200">
            <div class="flex justify-around py-2">
                <a href="{{ route('daily-readings.index') }}" class="flex flex-col items-center py-2 px-3 text-gray-600 hover:text-blue-600">
                    <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                    </svg>
                    <span class="text-xs">Readings</span>
                </a>
                <a href="{{ route('billing-cycles.index') }}" class="flex flex-col items-center py-2 px-3 text-gray-600 hover:text-blue-600">
                    <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                    </svg>
                    <span class="text-xs">Cycles</span>
                </a>
            </div>
        </div>

        <!-- Add padding for mobile bottom navigation (Always Visible) -->
        <div class="pb-20"></div>
    </div>

    <!-- PWA Install Prompt -->
    <x-pwa-install-prompt />
</body>
</html>
