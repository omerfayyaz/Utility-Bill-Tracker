<x-app-layout>
    <div class="space-y-6">
        <!-- Header -->
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
            <div>
                <h2 class="text-2xl font-bold text-gray-900">Billing Cycles</h2>
                <p class="mt-1 text-sm text-gray-600">
                    Manage your utility billing cycles
                </p>
            </div>
            <div class="mt-4 sm:mt-0">
                <a href="{{ route('billing-cycles.create') }}" class="inline-flex items-center px-4 py-2 bg-blue-600 border border-transparent rounded-lg font-semibold text-xs text-white uppercase tracking-widest hover:bg-blue-700 focus:bg-blue-700 active:bg-blue-900 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition ease-in-out duration-150">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                    </svg>
                    New Cycle
                </a>
            </div>
        </div>

        @if($billingCycles->count() > 0)
            <!-- Cycles List -->
            <div class="bg-white shadow overflow-hidden sm:rounded-lg">
                <ul class="divide-y divide-gray-200">
                    @foreach($billingCycles as $cycle)
                        <li>
                            <div class="px-4 py-4 sm:px-6 cursor-pointer hover:bg-gray-50 transition-colors duration-150" onclick="window.location.href='{{ route('billing-cycles.show', $cycle) }}'">
                                <div class="flex items-center justify-between">
                                    <div class="flex items-center">
                                        <div class="flex-shrink-0">
                                            <div class="h-10 w-10 rounded-full {{ $cycle->isActive() ? 'bg-green-100' : 'bg-gray-100' }} flex items-center justify-center">
                                                <svg class="h-6 w-6 {{ $cycle->isActive() ? 'text-green-600' : 'text-gray-600' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                                </svg>
                                            </div>
                                        </div>
                                        <div class="ml-4">
                                            <div class="flex items-center">
                                                <p class="text-sm font-medium text-gray-900">
                                                    {{ $cycle->name }}
                                                </p>
                                                @if($cycle->isActive())
                                                    <span class="ml-2 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                                        Active
                                                    </span>
                                                @endif
                                            </div>
                                            <div class="mt-1 flex items-center text-sm text-gray-500">
                                                <p>{{ $cycle->start_date->format('M d, Y') }} - {{ $cycle->end_date ? $cycle->end_date->format('M d, Y') : 'Ongoing' }}</p>
                                            </div>
                                            <div class="mt-1 text-sm text-gray-500">
                                                <p>Start: {{ number_format($cycle->start_reading, 2) }} units</p>
                                                @if($cycle->end_reading)
                                                    <p>End: {{ number_format($cycle->end_reading, 2) }} units</p>
                                                @endif
                                            </div>
                                        </div>
                                    </div>
                                    <div class="flex flex-col items-end">
                                        <div class="text-right">
                                            <p class="text-lg font-semibold text-gray-900">
                                                {{ number_format($cycle->total_consumed_units, 2) }}
                                            </p>
                                            <p class="text-sm text-gray-500">Total Consumed</p>
                                        </div>
                                        <div class="mt-2 flex space-x-2" onclick="event.stopPropagation()">
                                            <!-- Edit and Delete buttons removed - moved to show view -->
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </li>
                    @endforeach
                </ul>
            </div>
        @else
            <!-- No Cycles -->
            <div class="bg-white shadow rounded-lg p-6 text-center">
                <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                </svg>
                <h3 class="mt-2 text-sm font-medium text-gray-900">No billing cycles</h3>
                <p class="mt-1 text-sm text-gray-500">
                    Get started by creating your first billing cycle.
                </p>
                <div class="mt-6">
                    <a href="{{ route('billing-cycles.create') }}" class="inline-flex items-center px-4 py-2 bg-blue-600 border border-transparent rounded-lg font-semibold text-xs text-white uppercase tracking-widest hover:bg-blue-700 focus:bg-blue-700 active:bg-blue-900 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition ease-in-out duration-150">
                        Create First Cycle
                    </a>
                </div>
            </div>
        @endif
    </div>
</x-app-layout>
