<x-app-layout>
    <div class="max-w-md mx-auto">
        <!-- Header -->
        <div class="text-center mb-8">
            <h2 class="text-2xl font-bold text-gray-900">Quick Add Today's Reading</h2>
            <p class="mt-2 text-sm text-gray-600">
                Add your reading for {{ now()->format('M d, Y') }}
            </p>
        </div>

        <!-- Current Cycle Info -->
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
            <div class="flex items-center">
                <div class="flex-shrink-0">
                    <svg class="h-5 w-5 text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                </div>
                <div class="ml-3">
                    <h3 class="text-sm font-medium text-blue-800">
                        Active Cycle: {{ $activeCycle->name }}
                    </h3>
                    <div class="mt-1 text-sm text-blue-700">
                        <p>Current reading: {{ number_format($activeCycle->current_reading, 2) }} units</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Error Messages -->
        @if($errors->any())
            <div class="mb-6 bg-red-50 border border-red-200 rounded-lg p-4">
                <div class="flex">
                    <div class="flex-shrink-0">
                        <svg class="h-5 w-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                        </svg>
                    </div>
                    <div class="ml-3">
                        <h3 class="text-sm font-medium text-red-800">
                            @if($errors->has('reading_time'))
                                Duplicate Reading Detected
                            @elseif($errors->has('reading_value'))
                                Invalid Reading Value
                            @else
                                Validation Error
                            @endif
                        </h3>
                        <div class="mt-2 text-sm text-red-700">
                            @foreach($errors->all() as $error)
                                <p>{{ $error }}</p>
                            @endforeach
                            @if($errors->has('reading_time'))
                                <div class="mt-2">
                                    <p class="font-medium">Suggestions:</p>
                                    <ul class="list-disc list-inside mt-1 space-y-1">
                                        <li>Choose a different time (e.g., 5 minutes later)</li>
                                        <li>Check existing readings for today</li>
                                        <li>Use the "Add Reading" option for a different date</li>
                                    </ul>
                                </div>
                            @elseif($errors->has('reading_value'))
                                <div class="mt-2">
                                    <p class="font-medium">Reading Value Rules:</p>
                                    <ul class="list-disc list-inside mt-1 space-y-1">
                                        <li>Must be greater than the previous reading</li>
                                        <li>Must be less than the next reading</li>
                                        <li>Must be greater than or equal to cycle start reading</li>
                                    </ul>
                                </div>
                            @endif
                        </div>
                    </div>
                </div>
            </div>
        @endif

        <!-- Form -->
        <div class="bg-white shadow rounded-lg p-6">
            <form action="{{ route('daily-readings.quick-store') }}" method="POST">
                @csrf
                <input type="hidden" name="billing_cycle_id" value="{{ $activeCycle->id }}">

                <div class="space-y-6">
                    <!-- Reading Time -->
                    <div>
                        <label for="reading_time" class="block text-sm font-medium text-gray-700">
                            Reading Time
                        </label>
                        <div class="mt-1">
                            <input type="time"
                                   name="reading_time"
                                   id="reading_time"
                                   value="{{ old('reading_time', now()->format('H:i')) }}"
                                   class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('reading_time') border-red-300 focus:ring-red-500 focus:border-red-500 @enderror"
                                   required>
                        </div>
                        @error('reading_time')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                        <p class="mt-1 text-sm text-gray-500">
                            You can add multiple readings per day with different times
                        </p>
                    </div>

                    <!-- Reading Value -->
                    <div>
                        <label for="reading_value" class="block text-sm font-medium text-gray-700">
                            Reading Value (units)
                        </label>
                        <div class="mt-1 relative rounded-md shadow-sm">
                            <input type="number"
                                   name="reading_value"
                                   id="reading_value"
                                   step="0.01"
                                   min="{{ $activeCycle->current_reading }}"
                                   value="{{ old('reading_value', $activeCycle->current_reading) }}"
                                   class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-lg @error('reading_value') border-red-300 focus:ring-red-500 focus:border-red-500 @enderror"
                                   placeholder="Enter reading value"
                                   required>
                        </div>
                        @error('reading_value')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                        <p class="mt-1 text-sm text-gray-500">
                            Must be greater than or equal to current reading ({{ number_format($activeCycle->current_reading, 2) }})
                        </p>
                    </div>

                    <!-- Notes -->
                    <div>
                        <label for="notes" class="block text-sm font-medium text-gray-700">
                            Notes (optional)
                        </label>
                        <div class="mt-1">
                            <textarea name="notes"
                                      id="notes"
                                      rows="3"
                                      class="block w-full px-3 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 @error('notes') border-red-300 focus:ring-red-500 focus:border-red-500 @enderror"
                                      placeholder="Any additional notes about this reading...">{{ old('notes') }}</textarea>
                        </div>
                        @error('notes')
                            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
                        @enderror
                    </div>

                    <!-- Submit Button -->
                    <div class="flex space-x-3">
                        <a href="{{ route('daily-readings.index') }}"
                           class="flex-1 inline-flex justify-center items-center px-4 py-3 border border-gray-300 rounded-lg font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition ease-in-out duration-150">
                            Cancel
                        </a>
                        <button type="submit"
                                class="flex-1 inline-flex justify-center items-center px-4 py-3 border border-transparent rounded-lg font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition ease-in-out duration-150">
                            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                            </svg>
                            Save
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- Multiple Readings Info -->
        <div class="mt-6 bg-green-50 border border-green-200 rounded-lg p-4">
            <div class="flex">
                <div class="flex-shrink-0">
                    <svg class="h-5 w-5 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                </div>
                <div class="ml-3">
                    <h3 class="text-sm font-medium text-green-800">
                        Multiple Readings Per Day
                    </h3>
                    <div class="mt-2 text-sm text-green-700">
                        <p>You can now add multiple readings on the same day with different times. This is useful for:</p>
                        <ul class="list-disc list-inside mt-1 space-y-1">
                            <li>Morning and evening readings</li>
                            <li>Before and after specific activities</li>
                            <li>Tracking usage patterns throughout the day</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Actions -->
        <div class="mt-6 bg-gray-50 rounded-lg p-4">
            <h3 class="text-sm font-medium text-gray-900 mb-3">Quick Actions</h3>
            <div class="space-y-2">
                <a href="{{ route('daily-readings.create') }}" class="flex items-center text-sm text-blue-600 hover:text-blue-800">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                    </svg>
                    Add reading for different date
                </a>
                <a href="{{ route('billing-cycles.show', $activeCycle) }}" class="flex items-center text-sm text-gray-600 hover:text-gray-800">
                    <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                    </svg>
                    View cycle details
                </a>
            </div>
        </div>
    </div>
</x-app-layout>
