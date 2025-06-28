<x-app-layout>
    <div class="max-w-2xl mx-auto">
        <!-- Header -->
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between mb-8">
            <div>
                <h2 class="text-2xl font-bold text-gray-900">Reading Details</h2>
                <p class="mt-2 text-sm text-gray-600">
                    View reading information and consumption data
                </p>
            </div>
            <div class="mt-4 sm:mt-0 flex space-x-3">
                <a href="{{ route('daily-readings.edit', $dailyReading) }}"
                   class="inline-flex items-center px-4 py-2 bg-gray-600 border border-transparent rounded-lg font-semibold text-xs text-white uppercase tracking-widest hover:bg-gray-700 focus:bg-gray-700 active:bg-gray-900 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition ease-in-out duration-150"
                   style="background-color: rgb(75 85 99) !important; color: white !important; border: none !important; border-radius: 0.5rem !important;">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                    </svg>
                    Edit Reading
                </a>
                <form action="{{ route('daily-readings.destroy', $dailyReading) }}" method="POST" class="inline">
                    @csrf
                    @method('DELETE')
                    <button type="submit"
                            onclick="return confirm('Are you sure you want to delete this reading? This action cannot be undone.')"
                            class="inline-flex items-center px-4 py-2 bg-red-600 border border-transparent rounded-lg font-semibold text-xs text-white uppercase tracking-widest hover:bg-red-700 focus:bg-red-700 active:bg-red-900 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 transition ease-in-out duration-150"
                            style="background-color: rgb(220 38 38) !important; color: white !important; border: none !important; border-radius: 0.5rem !important;">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                        </svg>
                        Delete Reading
                    </button>
                </form>
            </div>
        </div>

        <!-- Reading Info Card -->
        <div class="bg-white shadow rounded-lg overflow-hidden">
            <div class="px-6 py-4 border-b border-gray-200">
                <h3 class="text-lg font-medium text-gray-900">
                    {{ $dailyReading->reading_date->format('l, M d, Y') }}
                </h3>
                <p class="text-sm text-gray-500">
                    {{ $dailyReading->reading_time->format('g:i A') }}
                </p>
            </div>

            <div class="px-6 py-4">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Reading Value -->
                    <div class="text-center">
                        <div class="text-3xl font-bold text-blue-600">
                            {{ number_format($dailyReading->reading_value, 2) }}
                        </div>
                        <div class="text-sm text-gray-500 mt-1">Reading Value (units)</div>
                    </div>

                    <!-- Consumption -->
                    @php
                        $readings = $dailyReading->billingCycle->dailyReadings()
                            ->orderBy('reading_date', 'asc')
                            ->orderBy('reading_time', 'asc')
                            ->get();
                        $previousValue = $dailyReading->billingCycle->start_reading;
                        foreach ($readings as $reading) {
                            if ($reading->id == $dailyReading->id) {
                                break;
                            }
                            $previousValue = $reading->reading_value;
                        }
                        $consumed = $dailyReading->reading_value - $previousValue;
                    @endphp
                    <div class="text-center">
                        @if($consumed > 0)
                            <div class="text-3xl font-bold text-green-600">
                                +{{ number_format($consumed, 2) }}
                            </div>
                            <div class="text-sm text-gray-500 mt-1">Consumed Since Previous</div>
                        @elseif($consumed < 0)
                            <div class="text-3xl font-bold text-red-600">
                                {{ number_format($consumed, 2) }}
                            </div>
                            <div class="text-sm text-gray-500 mt-1">Consumed Since Previous</div>
                        @else
                            <div class="text-3xl font-bold text-gray-600">
                                0.00
                            </div>
                            <div class="text-sm text-gray-500 mt-1">No Change</div>
                        @endif
                    </div>
                </div>

                <!-- Notes -->
                @if($dailyReading->notes)
                    <div class="mt-6 pt-6 border-t border-gray-200">
                        <h4 class="text-sm font-medium text-gray-900 mb-2">Notes</h4>
                        <p class="text-sm text-gray-600">{{ $dailyReading->notes }}</p>
                    </div>
                @endif
            </div>
        </div>

        <!-- Billing Cycle Info -->
        <div class="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div class="flex items-center">
                <div class="flex-shrink-0">
                    <svg class="h-5 w-5 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                    </svg>
                </div>
                <div class="ml-3">
                    <h3 class="text-sm font-medium text-blue-800">
                        Billing Cycle: {{ $dailyReading->billingCycle->name }}
                    </h3>
                    <div class="mt-1 text-sm text-blue-700">
                        <p>Start: {{ $dailyReading->billingCycle->start_date->format('M d, Y') }} ({{ number_format($dailyReading->billingCycle->start_reading, 2) }} units)</p>
                        <p>Total Consumed: {{ number_format($dailyReading->billingCycle->total_consumed_units, 2) }} units</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</x-app-layout>
