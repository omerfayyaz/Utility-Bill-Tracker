<x-app-layout>
    <div class="space-y-6">
        <!-- Header -->
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between">
            <div>
                <h2 class="text-2xl font-bold text-gray-900">{{ $billingCycle->name }}</h2>
                <p class="mt-1 text-sm text-gray-600">
                    Billing cycle details and readings
                </p>
            </div>
            <div class="mt-4 sm:mt-0" style="display: flex; justify-content: space-between; flex-direction: row-reverse;">

                <form action="{{ route('billing-cycles.destroy', $billingCycle) }}" method="POST" class="inline">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="inline-flex items-center px-4 py-2 !bg-red-600 !text-white border border-transparent rounded-lg font-semibold text-xs uppercase tracking-widest hover:!bg-red-700 focus:!bg-red-700 active:!bg-red-900 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 transition ease-in-out duration-150"
                        style="background-color: rgb(220 38 38) !important; color: white !important;"
                        onclick="return confirm('Are you sure you want to delete this billing cycle? This action cannot be undone.')">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                        </svg>
                    </button>
                </form>

                @if($billingCycle->isActive())

                    <a href="{{ route('billing-cycles.edit', $billingCycle) }}" class="inline-flex items-center px-4 py-2 bg-gray-600 border border-transparent rounded-lg font-semibold text-xs text-white uppercase tracking-widest hover:bg-gray-700 focus:bg-gray-700 active:bg-gray-900 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition ease-in-out duration-150">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
                        </svg>
                        Edit Cycle
                    </a>

                    <a href="{{ route('daily-readings.create', ['billing_cycle_id' => $billingCycle->id]) }}" class="inline-flex items-center px-4 py-2 bg-blue-600 border border-transparent rounded-lg font-semibold text-xs text-white uppercase tracking-widest hover:bg-blue-700 focus:bg-blue-700 active:bg-blue-900 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition ease-in-out duration-150">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                        </svg>
                        Add Reading
                    </a>
                @endif
            </div>
        </div>

        <!-- Cycle Stats -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <!-- Current Reading -->
            <div class="bg-white overflow-hidden shadow rounded-lg">
                <div class="p-5">
                    <div class="flex items-center">
                        <div class="flex-shrink-0">
                            <svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                            </svg>
                        </div>
                        <div class="ml-5 w-0 flex-1">
                            <dl>
                                <dt class="text-sm font-medium text-gray-500 truncate">
                                    Current Reading
                                </dt>
                                <dd class="text-lg font-medium text-gray-900">
                                    {{ number_format($billingCycle->current_reading, 2) }}
                                </dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Total Consumed -->
            <div class="bg-white overflow-hidden shadow rounded-lg">
                <div class="p-5">
                    <div class="flex items-center">
                        <div class="flex-shrink-0">
                            <svg class="h-6 w-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6"></path>
                            </svg>
                        </div>
                        <div class="ml-5 w-0 flex-1">
                            <dl>
                                <dt class="text-sm font-medium text-gray-500 truncate">
                                    Total Consumed
                                </dt>
                                <dd class="text-lg font-medium text-gray-900">
                                    {{ number_format($billingCycle->total_consumed_units, 2) }}
                                </dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Days Elapsed -->
            <div class="bg-white overflow-hidden shadow rounded-lg">
                <div class="p-5">
                    <div class="flex items-center">
                        <div class="flex-shrink-0">
                            <svg class="h-6 w-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                            </svg>
                        </div>
                        <div class="ml-5 w-0 flex-1">
                            <dl>
                                <dt class="text-sm font-medium text-gray-500 truncate">
                                    Days Elapsed
                                </dt>
                                <dd class="text-lg font-medium text-gray-900">
                                    {{ $billingCycle->days_elapsed }}
                                </dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Status -->
            <div class="bg-white overflow-hidden shadow rounded-lg">
                <div class="p-5">
                    <div class="flex items-center">
                        <div class="flex-shrink-0">
                            <svg class="h-6 w-6 {{ $billingCycle->isActive() ? 'text-green-600' : 'text-gray-600' }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                            </svg>
                        </div>
                        <div class="ml-5 w-0 flex-1">
                            <dl>
                                <dt class="text-sm font-medium text-gray-500 truncate">
                                    Status
                                </dt>
                                <dd class="text-lg font-medium {{ $billingCycle->isActive() ? 'text-green-600' : 'text-gray-600' }}">
                                    {{ $billingCycle->isActive() ? 'Active' : 'Inactive' }}
                                </dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Cycle Details -->
        <div class="bg-white shadow overflow-hidden sm:rounded-lg">
            <div class="px-4 py-5 sm:px-6">
                <h3 class="text-lg leading-6 font-medium text-gray-900">
                    Cycle Information
                </h3>
            </div>
            <div class="border-t border-gray-200">
                <dl>
                    <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                        <dt class="text-sm font-medium text-gray-500">
                            Start Date
                        </dt>
                        <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                            {{ $billingCycle->start_date->format('F d, Y') }}
                        </dd>
                    </div>
                    <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                        <dt class="text-sm font-medium text-gray-500">
                            Start Reading
                        </dt>
                        <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                            {{ number_format($billingCycle->start_reading, 2) }} units
                        </dd>
                    </div>
                    @if($billingCycle->end_date)
                        <div class="bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                            <dt class="text-sm font-medium text-gray-500">
                                End Date
                            </dt>
                            <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                                {{ $billingCycle->end_date->format('F d, Y') }}
                            </dd>
                        </div>
                        <div class="bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6">
                            <dt class="text-sm font-medium text-gray-500">
                                End Reading
                            </dt>
                            <dd class="mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2">
                                {{ number_format($billingCycle->end_reading, 2) }} units
                            </dd>
                        </div>
                    @endif
                </dl>
            </div>
        </div>

        <!-- Readings List -->
        <div class="bg-white shadow overflow-hidden sm:rounded-lg">
            <div class="px-4 py-5 sm:px-6 border-b border-gray-200">
                <h3 class="text-lg leading-6 font-medium text-gray-900">
                    All Readings
                </h3>
                <p class="mt-1 max-w-2xl text-sm text-gray-500">
                    Multiple readings per day are now supported
                </p>
            </div>
            @if($billingCycle->dailyReadings->count() > 0)
                <ul class="divide-y divide-gray-200">
                    @php
                        $items = [];
                        $previousValue = $billingCycle->start_reading;
                        foreach ($billingCycle->dailyReadings as $reading) {
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
                                <div class="flex items-center space-x-2">
                                    <div class="flex-shrink-0">
                                        <svg class="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                                        </svg>
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endforeach
                    @if($currentDate !== null)
                        </div> <!-- Close last date group -->
                    @endif
                </ul>
            @else
                <div class="px-4 py-8 text-center">
                    <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                    </svg>
                    <h3 class="mt-2 text-sm font-medium text-gray-900">No readings yet</h3>
                    <p class="mt-1 text-sm text-gray-500">
                        Get started by adding your first reading for this cycle.
                    </p>
                    <div class="mt-6">
                        @if($billingCycle->isActive())
                            <a href="{{ route('daily-readings.create', ['billing_cycle_id' => $billingCycle->id]) }}" class="inline-flex items-center px-4 py-2 bg-blue-600 border border-transparent rounded-lg font-semibold text-xs text-white uppercase tracking-widest hover:bg-blue-700 focus:bg-blue-700 active:bg-blue-900 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition ease-in-out duration-150">
                                Add First Reading
                            </a>
                        @else
                            <span class="inline-flex items-center px-4 py-2 bg-gray-300 border border-transparent rounded-lg font-semibold text-xs text-white uppercase tracking-widest cursor-not-allowed" title="You can only add readings to the active cycle.">
                                Add First Reading
                            </span>
                        @endif
                    </div>
                </div>
            @endif
        </div>
    </div>
</x-app-layout>
