<x-app-layout>
    <div class="space-y-6">
        <!-- Header -->

        @if(!$activeCycle)
            <div>
                <h2 class="text-2xl font-bold text-gray-900">Daily Readings</h2>
                <p class="mt-1 text-sm text-gray-600">
                    Track your utility consumption daily
                </p>
            </div>

            <!-- No Active Cycle -->
            <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-6">
                <div class="flex">
                    <div class="flex-shrink-0">
                        <svg class="h-5 w-5 text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                        </svg>
                    </div>
                    <div class="ml-3">
                        <h3 class="text-sm font-medium text-yellow-800">
                            No Active Billing Cycle
                        </h3>
                        <div class="mt-2 text-sm text-yellow-700">
                            <p>You need to create a billing cycle before adding readings.</p>
                        </div>
                        <div class="mt-4">
                            <a href="{{ route('billing-cycles.create') }}" class="inline-flex items-center px-4 py-2 bg-yellow-600 border border-transparent rounded-lg font-semibold text-xs text-white uppercase tracking-widest hover:bg-yellow-700 focus:bg-yellow-700 active:bg-yellow-900 focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:ring-offset-2 transition ease-in-out duration-150">
                                Create Billing Cycle
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        @else
            <!-- Active Cycle Info -->
            <div class="bg-white overflow-hidden shadow rounded-lg">
                <div class="px-4 py-5 sm:p-6">
                    <div class="flex items-center justify-between">
                        <div class="text-center w-full">
                            <h3 class="text-lg leading-6 font-medium text-gray-900">
                                Active Cycle
                            </h3>
                            <h3 class="text-3xl leading-6 font-medium text-gray-900 mt-2 mb-3">
                                {{ $activeCycle->name }}
                            </h3>
                            <p class="mt-1 text-sm text-gray-500">
                                Started {{ $activeCycle->start_date->format('M d, Y') }} with {{ number_format($activeCycle->start_reading, 2) }} units
                            </p>
                        </div>
                    </div>
                    <div class="flex items-center justify-between w-full mt-3">
                        <div class="text-center w-full">
                            <p class="text-2xl font-bold text-blue-600">
                                {{ number_format($activeCycle->current_reading, 2) }}
                            </p>
                            <p class="text-sm text-gray-500">Current Reading</p>
                        </div>
                    </div>
                    <div class="mt-4 grid grid-cols-2 gap-4">
                        <div class="text-center">
                            <p class="text-lg font-semibold text-gray-900">
                                {{ number_format($activeCycle->total_consumed_units, 2) }}
                            </p>
                            <p class="text-sm text-gray-500">Total Consumed</p>
                        </div>
                        <div class="text-center">
                            <p class="text-lg font-semibold text-gray-900">
                                {{ $activeCycle->days_elapsed }}
                            </p>
                            <p class="text-sm text-gray-500">Days Passed</p>
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <h2 class="text-2xl font-bold text-gray-900">Daily Readings</h2>
                <p class="mt-1 text-sm text-gray-600">
                    Track your utility consumption daily
                </p>
            </div>

            <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
                <div class="sm:mt-0 flex space-x-3">
                    <a style="width: 100%" href="{{ route('daily-readings.create') }}" class="inline-flex items-center px-4 py-2 bg-blue-600 border border-transparent rounded-lg font-semibold text-xs text-white uppercase tracking-widest hover:bg-blue-700 focus:bg-blue-700 active:bg-blue-900 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition ease-in-out duration-150">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                        </svg>
                        Add New Reading
                    </a>
                </div>
            </div>

            <!-- Readings List -->
            @if($readings->count() > 0)
                <div class="bg-white shadow overflow-hidden sm:rounded-lg">
                    <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
                        <h3 class="text-lg leading-6 font-medium text-gray-900">
                            All Readings
                        </h3>
                        <p class="mt-1 max-w-2xl text-sm text-gray-500">
                            Multiple readings per day are now supported
                        </p>
                    </div>
                    <ul class="divide-y divide-gray-200">
                        @php
                            $items = [];
                            $previousValue = $activeCycle->start_reading;
                            foreach ($readings as $reading) {
                                $consumed = $reading->reading_value - $previousValue;
                                $items[] = (object)[
                                    'reading' => $reading,
                                    'consumed' => $consumed,
                                ];
                                $previousValue = $reading->reading_value;
                            }
                            $items = array_reverse($items);
                            $currentDate = null;
                        @endphp
                        @foreach($items as $item)
                            @if($currentDate !== $item->reading->reading_date->format('Y-m-d'))
                                @if($currentDate !== null)
                                    </div> <!-- Close previous date group -->
                                @endif
                                @php
                                    $currentDate = $item->reading->reading_date->format('Y-m-d');
                                @endphp
                                <li class="bg-gray-50">
                                    <div class="px-4 py-3 sm:px-6">
                                        <h4 class="text-sm font-medium text-gray-900">
                                            {{ $item->reading->reading_date->format('l, M d, Y') }}
                                        </h4>
                                    </div>
                                    <div class="space-y-1">
                            @endif

                            <div class="px-4 py-3 sm:px-6 bg-white">
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center flex-1 cursor-pointer" onclick="window.location.href='{{ route('daily-readings.show', $item->reading) }}'">
                                        <div class="flex-shrink-0">
                                            <div class="h-8 w-8 rounded-full bg-blue-100 flex items-center justify-center">
                                                <svg class="h-4 w-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                                </svg>
                                            </div>
                                        </div>
                                        <div class="ml-3 flex-1">
                                            <div class="flex items-center">
                                                <p class="text-sm font-medium text-gray-900">
                                                    {{ $item->reading->reading_time->format('g:i A') }}
                                                </p>
                                                <span class="ml-2 inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                                                    {{ number_format($item->reading->reading_value, 2) }} units
                                                </span>
                                            </div>
                                            <div class="mt-1 flex items-center text-sm text-gray-500">
                                                @if($item->consumed > 0)
                                                    <p class="text-green-600">+{{ number_format($item->consumed, 2) }} consumed</p>
                                                @elseif($item->consumed < 0)
                                                    <p class="text-red-600">{{ number_format($item->consumed, 2) }} consumed</p>
                                                @else
                                                    <p class="text-gray-500">No change</p>
                                                @endif
                                            </div>
                                            @if($item->reading->notes)
                                                <p class="mt-1 text-sm text-gray-500">{{ $item->reading->notes }}</p>
                                            @endif
                                        </div>
                                    </div>
                                    <div class="flex-shrink-0">
                                        <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                                        </svg>
                                    </div>
                                </div>
                            </div>
                        @endforeach
                        @if($currentDate !== null)
                            </div> <!-- Close last date group -->
                        @endif
                    </ul>
                </div>
            @else
                <!-- No Readings -->
                <div class="bg-white shadow rounded-lg p-6 text-center">
                    <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                    </svg>
                    <h3 class="mt-2 text-sm font-medium text-gray-900">No readings yet</h3>
                    <p class="mt-1 text-sm text-gray-500">
                        Get started by adding your first reading.
                    </p>
                    <div class="mt-6">
                        <a href="{{ route('daily-readings.create') }}" class="inline-flex items-center px-4 py-2 bg-blue-600 border border-transparent rounded-lg font-semibold text-xs text-white uppercase tracking-widest hover:bg-blue-700 focus:bg-blue-700 active:bg-blue-900 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition ease-in-out duration-150">
                            Add First Reading
                        </a>
                    </div>
                </div>
            @endif
        @endif
    </div>
</x-app-layout>
