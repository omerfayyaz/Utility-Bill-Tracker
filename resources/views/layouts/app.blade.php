<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Utility Bill Logger') }}</title>

    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700" rel="stylesheet" />

    <!-- Scripts -->
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="font-sans antialiased bg-gray-50">
    <div class="min-h-screen">
        <!-- Header -->
        <header class="bg-white shadow-sm border-b border-gray-200">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between items-center py-4">
                    <div class="flex items-center">
                        <h1 class="text-xl font-semibold text-gray-900">
                            <a href="{{ route('daily-readings.index') }}" class="hover:text-blue-600">
                                Utility Logger
                            </a>
                        </h1>
                    </div>
                    <nav class="flex space-x-4">
                        <a href="{{ route('daily-readings.index') }}" class="text-gray-600 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium">
                            Readings
                        </a>
                        <a href="{{ route('billing-cycles.index') }}" class="text-gray-600 hover:text-blue-600 px-3 py-2 rounded-md text-sm font-medium">
                            Cycles
                        </a>
                    </nav>
                </div>
            </div>
        </header>

        <!-- Page Content -->
        <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
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

        <!-- Mobile Bottom Navigation -->
        <div class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 md:hidden">
            <div class="flex justify-around py-2">
                <a href="{{ route('daily-readings.index') }}" class="flex flex-col items-center py-2 px-3 text-gray-600 hover:text-blue-600">
                    <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                    </svg>
                    <span class="text-xs">Readings</span>
                </a>
                <a href="{{ route('daily-readings.quick-add') }}" class="flex flex-col items-center py-2 px-3 text-blue-600">
                    <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                    </svg>
                    <span class="text-xs">Quick Add</span>
                </a>
                <a href="{{ route('billing-cycles.index') }}" class="flex flex-col items-center py-2 px-3 text-gray-600 hover:text-blue-600">
                    <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                    </svg>
                    <span class="text-xs">Cycles</span>
                </a>
            </div>
        </div>

        <!-- Add padding for mobile bottom navigation -->
        <div class="pb-20 md:pb-0"></div>
    </div>
</body>
</html>
